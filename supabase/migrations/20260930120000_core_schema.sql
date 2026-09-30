-- Core schema for the pilot with a single partner dealer.
-- Tables for later slices (visit_slots, inspection_results, internal_notes,
-- email_log) are added in their own migrations.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

create type public.user_role as enum ('dealer_user', 'admin');

-- RF-34. 'draft' is not part of RF-34: it covers RF-09 and the RF-38 funnel,
-- and is never visible to the dealer.
create type public.request_status as enum (
  'draft',
  'received',
  'info_requested',
  'quoted',
  'client_interested',
  'visit_scheduled',
  'inspection_done',
  'closed_purchased',
  'closed_no_deal',
  'expired'
);

-- RF-04: 8 exterior + 4 interior angles. RF-08: optional tire tread photo.
create type public.photo_angle as enum (
  'front',
  'rear',
  'left_side',
  'right_side',
  'front_left',
  'front_right',
  'rear_left',
  'rear_right',
  'dashboard',
  'front_seats',
  'rear_seats',
  'trunk',
  'tire_tread'
);

-- RF-07
create type public.vehicle_condition as enum ('excellent', 'good', 'fair', 'poor');

-- RF-08
create type public.tire_state as enum ('new', 'good', 'medium_wear', 'high_wear');

-- ---------------------------------------------------------------------------
-- Dealers and staff (RF-29, RF-30, RF-32)
-- ---------------------------------------------------------------------------

create table public.dealers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  legal_name text,
  timezone text not null default 'America/Montevideo',
  created_at timestamptz not null default now()
);

-- A single branch in the pilot; the table allows adding more later.
create table public.branches (
  id uuid primary key default gen_random_uuid(),
  dealer_id uuid not null references public.dealers (id) on delete cascade,
  name text not null,
  address text not null,
  opening_hours text,
  phone text,
  email text,
  visit_documents text,
  created_at timestamptz not null default now()
);

create index branches_dealer_id_idx on public.branches (dealer_id);

-- Staff only. Clients authenticate with an email OTP but never get a profile.
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role public.user_role not null,
  dealer_id uuid references public.dealers (id) on delete restrict,
  full_name text,
  created_at timestamptz not null default now(),
  constraint profiles_dealer_user_has_dealer check (role <> 'dealer_user' or dealer_id is not null)
);

create index profiles_dealer_id_idx on public.profiles (dealer_id);

-- ---------------------------------------------------------------------------
-- Configuration
-- ---------------------------------------------------------------------------

-- Single-row table with typed parameters. Values marked "to confirm" are
-- pending with the dealer (see docs/alcance-mvp.md).
create table public.settings (
  id smallint primary key default 1 constraint settings_single_row check (id = 1),
  -- RF-24, RF-27
  price_tolerance numeric(5, 4) not null default 0.05
    constraint settings_price_tolerance_range check (price_tolerance >= 0 and price_tolerance < 1),
  -- RF-09
  draft_ttl_days integer not null default 30 check (draft_ttl_days > 0),
  -- RF-22 (to confirm)
  offer_validity_days integer not null default 7 check (offer_validity_days > 0),
  -- Photo cleanup after a request is closed or expired (to confirm)
  photo_retention_days integer not null default 60 check (photo_retention_days > 0),
  -- Quote deadline: morning submissions are quoted the same day, afternoon
  -- submissions the next business morning (to confirm).
  quote_cutoff_time time not null default '12:00',
  quote_same_day_deadline time not null default '19:00',
  quote_next_morning_deadline time not null default '12:00',
  -- ISO day of week, 1 = Monday ... 7 = Sunday
  business_days smallint[] not null default '{1,2,3,4,5}',
  -- RF-01 (to confirm)
  max_vehicle_age_years integer check (max_vehicle_age_years > 0),
  excluded_brands text[] not null default '{}',
  updated_at timestamptz not null default now()
);

insert into public.settings (id) values (1);

create table public.holidays (
  day date primary key,
  description text not null
);

-- RF-03: brands and models provided by the dealer.
create table public.vehicle_catalog (
  id bigint generated always as identity primary key,
  brand text not null,
  model text not null,
  active boolean not null default true,
  constraint vehicle_catalog_brand_model_key unique (brand, model)
);

-- ---------------------------------------------------------------------------
-- Requests
-- ---------------------------------------------------------------------------

create table public.requests (
  id uuid primary key default gen_random_uuid(),
  -- RF-13: human-readable request number
  request_number bigint generated always as identity unique,
  status public.request_status not null default 'draft',
  -- Assigned on submission; the pilot has a single dealer.
  dealer_id uuid references public.dealers (id) on delete restrict,
  -- Auth user created by the email OTP verification (RF-11).
  client_user_id uuid references auth.users (id) on delete set null,

  -- RF-02
  contact_name text,
  contact_phone text,
  contact_email text,

  -- RF-03
  vehicle_catalog_id bigint references public.vehicle_catalog (id) on delete restrict,
  vehicle_version text,
  vehicle_year smallint check (vehicle_year between 1950 and 2100),
  mileage_km integer check (mileage_km >= 0),

  -- RF-06
  official_service boolean,
  has_service_records boolean,
  last_service_date date,
  last_service_km integer check (last_service_km >= 0),

  -- RF-07
  condition public.vehicle_condition,
  known_faults text,
  fluid_leaks text,

  -- RF-08
  tire_state public.tire_state,
  tire_age text,

  -- RF-11: consent with date and accepted text version
  consent_at timestamptz,
  consent_version text,

  draft_expires_at timestamptz,
  submitted_at timestamptz,
  quote_due_at timestamptz,
  overdue_notified_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint requests_consent_complete check ((consent_at is null) = (consent_version is null)),
  constraint requests_submitted_complete check (
    status = 'draft'
    or (submitted_at is not null and dealer_id is not null and consent_at is not null)
  )
);

create index requests_dealer_status_idx on public.requests (dealer_id, status);
create index requests_client_user_id_idx on public.requests (client_user_id);
create index requests_submitted_at_idx on public.requests (submitted_at);

-- Only the SHA-256 of the private link token is stored. Kept in its own table,
-- with RLS and no policies, so it is never readable through the API.
create table public.request_tokens (
  request_id uuid primary key references public.requests (id) on delete cascade,
  token_hash bytea not null unique,
  created_at timestamptz not null default now()
);

-- RF-04, RF-05: photos live in Storage; only the path and metadata are stored.
create table public.photos (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.requests (id) on delete cascade,
  angle public.photo_angle not null,
  storage_path text not null unique,
  content_hash text,
  width integer check (width > 0),
  height integer check (height > 0),
  size_bytes integer check (size_bytes > 0),
  created_at timestamptz not null default now(),
  constraint photos_request_angle_key unique (request_id, angle)
);

-- RF-22: a single value per version; each correction is a new version.
create table public.offers (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.requests (id) on delete cascade,
  version integer not null check (version > 0),
  amount numeric(12, 2) not null check (amount > 0),
  currency char(3) not null default 'USD',
  valid_until timestamptz not null,
  notes text,
  branch_id uuid references public.branches (id) on delete restrict,
  created_by uuid references auth.users (id) on delete set null default auth.uid(),
  created_at timestamptz not null default now(),
  constraint offers_request_version_key unique (request_id, version)
);

-- RF-34, RF-36: every status change, with date and user.
create table public.status_events (
  id bigint generated always as identity primary key,
  request_id uuid not null references public.requests (id) on delete cascade,
  from_status public.request_status,
  to_status public.request_status not null,
  changed_by uuid references auth.users (id) on delete set null,
  changed_at timestamptz not null default now()
);

create index status_events_request_id_idx on public.status_events (request_id, changed_at);

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------

create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger requests_set_updated_at
  before update on public.requests
  for each row execute function public.set_updated_at();

create trigger settings_set_updated_at
  before update on public.settings
  for each row execute function public.set_updated_at();

-- RF-34: record every status change. Security definer so that no role needs
-- insert rights on status_events.
create function public.record_status_event()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' or new.status is distinct from old.status then
    insert into public.status_events (request_id, from_status, to_status, changed_by)
    values (
      new.id,
      case when tg_op = 'UPDATE' then old.status end,
      new.status,
      auth.uid()
    );
  end if;
  return new;
end;
$$;

revoke execute on function public.record_status_event() from public, anon, authenticated;

create trigger requests_record_status_event
  after insert or update of status on public.requests
  for each row execute function public.record_status_event();
