-- Row Level Security for every table, private link token and photo storage.
--
-- Access model:
--   anon           -> settings, holidays and active catalog; own request only
--                     through get_request_by_token().
--   client         -> authenticated user WITHOUT a profile (email OTP, RF-11);
--                     only their own draft.
--   dealer_user    -> authenticated user with a profile; submitted requests of
--                     their dealer.
--   admin          -> everything (read).
-- Writes beyond what is granted here are added in the slice that needs them.

-- ---------------------------------------------------------------------------
-- Helpers (private schema: not exposed through the API)
-- ---------------------------------------------------------------------------

create schema if not exists private;
grant usage on schema private to anon, authenticated;

create function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'admin'
  );
$$;

create function private.current_dealer_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select dealer_id from public.profiles
  where id = (select auth.uid()) and role = 'dealer_user';
$$;

revoke execute on all functions in schema private from public;
grant execute on function private.is_admin() to anon, authenticated;
grant execute on function private.current_dealer_id() to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Enable RLS everywhere
-- ---------------------------------------------------------------------------

alter table public.dealers enable row level security;
alter table public.branches enable row level security;
alter table public.profiles enable row level security;
alter table public.settings enable row level security;
alter table public.holidays enable row level security;
alter table public.vehicle_catalog enable row level security;
alter table public.requests enable row level security;
alter table public.request_tokens enable row level security;
alter table public.photos enable row level security;
alter table public.offers enable row level security;
alter table public.status_events enable row level security;

-- ---------------------------------------------------------------------------
-- Policies
-- ---------------------------------------------------------------------------

create policy "staff read own dealer"
  on public.dealers for select to authenticated
  using (id = (select private.current_dealer_id()) or (select private.is_admin()));

create policy "staff read own dealer branches"
  on public.branches for select to authenticated
  using (dealer_id = (select private.current_dealer_id()) or (select private.is_admin()));

create policy "users read own profile, admin reads all"
  on public.profiles for select to authenticated
  using (id = (select auth.uid()) or (select private.is_admin()));

create policy "everyone reads settings"
  on public.settings for select to anon, authenticated
  using (true);

create policy "everyone reads holidays"
  on public.holidays for select to anon, authenticated
  using (true);

create policy "everyone reads active catalog, admin reads all"
  on public.vehicle_catalog for select to anon, authenticated
  using (active or (select private.is_admin()));

-- Requests: staff never see drafts; clients only see their own draft.
create policy "dealer reads submitted requests of own dealer"
  on public.requests for select to authenticated
  using (
    (dealer_id = (select private.current_dealer_id()) and status <> 'draft')
    or (select private.is_admin())
  );

create policy "client reads own draft"
  on public.requests for select to authenticated
  using (client_user_id = (select auth.uid()) and status = 'draft');

create policy "client updates own draft"
  on public.requests for update to authenticated
  using (client_user_id = (select auth.uid()) and status = 'draft')
  with check (client_user_id = (select auth.uid()) and status = 'draft');

-- Clients may only edit form fields; status, dealer, token and deadlines are
-- changed through security definer functions.
revoke insert, update, delete on public.requests from anon, authenticated;
grant update (
  contact_name, contact_phone, contact_email,
  vehicle_catalog_id, vehicle_version, vehicle_year, mileage_km,
  official_service, has_service_records, last_service_date, last_service_km,
  condition, known_faults, fluid_leaks,
  tire_state, tire_age
) on public.requests to authenticated;

-- request_tokens: RLS on and no policies; never reachable through the API.
revoke all on public.request_tokens from anon, authenticated;

-- Child tables inherit visibility from requests (the subquery runs with the
-- caller's RLS on requests).
create policy "read photos of visible requests"
  on public.photos for select to authenticated
  using (exists (select 1 from public.requests r where r.id = request_id));

create policy "read offers of visible requests"
  on public.offers for select to authenticated
  using (exists (select 1 from public.requests r where r.id = request_id));

create policy "read status events of visible requests"
  on public.status_events for select to authenticated
  using (exists (select 1 from public.requests r where r.id = request_id));

revoke insert, update, delete on public.status_events from anon, authenticated;

-- ---------------------------------------------------------------------------
-- Private link token (RF-09, RF-13)
-- ---------------------------------------------------------------------------

-- 256 random bits, base64url without padding (43 characters). Returns the
-- plain token once; only its SHA-256 is stored. Replaces any previous token.
create function private.issue_request_token(p_request_id uuid)
returns text
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_token text;
begin
  v_token := rtrim(
    translate(encode(extensions.gen_random_bytes(32), 'base64'), '+/', '-_'),
    '='
  );

  insert into public.request_tokens (request_id, token_hash)
  values (p_request_id, extensions.digest(v_token, 'sha256'))
  on conflict (request_id) do update
    set token_hash = excluded.token_hash, created_at = now();

  return v_token;
end;
$$;

-- Not callable from the API; used by the RPCs of slice 2.
revoke execute on function private.issue_request_token(uuid) from public, anon, authenticated;

-- Client view of a request from the private link, without login.
-- Returns no rows for an unknown or malformed token.
create function public.get_request_by_token(p_token text)
returns table (
  request_number bigint,
  status public.request_status,
  created_at timestamptz,
  submitted_at timestamptz,
  quote_due_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select r.request_number, r.status, r.created_at, r.submitted_at, r.quote_due_at
  from public.request_tokens t
  join public.requests r on r.id = t.request_id
  where p_token ~ '^[A-Za-z0-9_-]{43}$'
    and t.token_hash = extensions.digest(p_token, 'sha256');
$$;

revoke execute on function public.get_request_by_token(text) from public;
grant execute on function public.get_request_by_token(text) to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Photo storage (private bucket; paths are "<request_id>/<angle>.jpg")
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('request-photos', 'request-photos', false, 5242880, array['image/jpeg', 'image/webp']);

create policy "read photos of visible requests"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'request-photos'
    and exists (
      select 1 from public.requests r
      where r.id::text = (storage.foldername(name))[1]
    )
  );
