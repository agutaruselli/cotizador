-- RLS, private link token and status history (RF-13, RF-32, RF-34).
-- Run with: npm run test:db
begin;
create extension if not exists pgtap with schema extensions;

select plan(34);

-- ---------------------------------------------------------------------------
-- Fixtures (ids are unique to this file so seed data does not interfere)
-- ---------------------------------------------------------------------------

insert into auth.users (id, email) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'dealer-a@test.local'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'dealer-b@test.local'),
  ('aaaaaaaa-0000-0000-0000-000000000003', 'admin@test.local'),
  ('aaaaaaaa-0000-0000-0000-000000000004', 'client-1@test.local'),
  ('aaaaaaaa-0000-0000-0000-000000000005', 'client-2@test.local');

insert into public.dealers (id, name) values
  ('bbbbbbbb-0000-0000-0000-00000000000a', 'Dealer A'),
  ('bbbbbbbb-0000-0000-0000-00000000000b', 'Dealer B');

insert into public.profiles (id, role, dealer_id) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'dealer_user', 'bbbbbbbb-0000-0000-0000-00000000000a'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'dealer_user', 'bbbbbbbb-0000-0000-0000-00000000000b'),
  ('aaaaaaaa-0000-0000-0000-000000000003', 'admin', null);

insert into public.requests (id, status, dealer_id, client_user_id, consent_at, consent_version, submitted_at) values
  ('cccccccc-0000-0000-0000-00000000000a', 'received', 'bbbbbbbb-0000-0000-0000-00000000000a', null, now(), 'test', now()),
  ('cccccccc-0000-0000-0000-00000000000b', 'received', 'bbbbbbbb-0000-0000-0000-00000000000b', null, now(), 'test', now()),
  ('cccccccc-0000-0000-0000-0000000000d1', 'draft', null, 'aaaaaaaa-0000-0000-0000-000000000004', null, null, null),
  ('cccccccc-0000-0000-0000-0000000000d2', 'draft', null, 'aaaaaaaa-0000-0000-0000-000000000005', null, null, null);

insert into public.photos (request_id, angle, storage_path) values
  ('cccccccc-0000-0000-0000-00000000000a', 'front', 'cccccccc-0000-0000-0000-00000000000a/front.jpg'),
  ('cccccccc-0000-0000-0000-00000000000b', 'front', 'cccccccc-0000-0000-0000-00000000000b/front.jpg');

insert into storage.objects (bucket_id, name) values
  ('request-photos', 'cccccccc-0000-0000-0000-00000000000a/front.jpg'),
  ('request-photos', 'cccccccc-0000-0000-0000-00000000000b/front.jpg');

-- Issued token for request B (checked as postgres); fixed token for request A
-- (used by anon, which cannot read this session's temp tables).
create temp table test_token as
  select private.issue_request_token('cccccccc-0000-0000-0000-00000000000b') as token;

insert into public.request_tokens (request_id, token_hash) values
  ('cccccccc-0000-0000-0000-00000000000a',
   extensions.digest('test-token-a-000000000000000000000000000000', 'sha256'));

-- ---------------------------------------------------------------------------
-- Global guarantees
-- ---------------------------------------------------------------------------

select is_empty(
  $$ select tablename from pg_tables where schemaname = 'public' and not rowsecurity $$,
  'RLS is enabled on every public table'
);

select ok(
  (select token ~ '^[A-Za-z0-9_-]{43}$' from test_token),
  'token is 43 base64url characters (256 bits)'
);

select is(
  (select token_hash from public.request_tokens where request_id = 'cccccccc-0000-0000-0000-00000000000b'),
  (select extensions.digest(token, 'sha256') from test_token),
  'only the SHA-256 of the token is stored'
);

select is(
  (select count(*)::int from public.status_events
   where request_id = 'cccccccc-0000-0000-0000-00000000000a' and from_status is null and to_status = 'received'),
  1,
  'RF-34: creating a request records its initial status'
);

-- ---------------------------------------------------------------------------
-- anon
-- ---------------------------------------------------------------------------

set local role anon;
set local request.jwt.claims = '{"role":"anon"}';

select is_empty('select id from public.requests', 'anon cannot read requests');
select is_empty('select id from public.photos', 'anon cannot read photos');
select is_empty('select id from public.offers', 'anon cannot read offers');
select is_empty('select id from public.status_events', 'anon cannot read status events');
select is_empty('select id from public.dealers', 'anon cannot read dealers');
select is_empty('select id from public.profiles', 'anon cannot read profiles');
select is_empty(
  $$ select id from storage.objects where bucket_id = 'request-photos' $$,
  'anon cannot list photo objects'
);
select throws_ok('select * from public.request_tokens', '42501', null, 'anon cannot read token hashes');
select isnt_empty('select id from public.settings', 'anon can read settings');

select is(
  (select count(*)::int from public.get_request_by_token('test-token-a-000000000000000000000000000000')),
  1,
  'RF-13: the private link token returns its request'
);
select is_empty(
  $$ select * from public.get_request_by_token('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA') $$,
  'a wrong token returns nothing'
);
select is_empty(
  $$ select * from public.get_request_by_token('short') $$,
  'a malformed token returns nothing'
);
select throws_ok(
  $$ select private.issue_request_token('cccccccc-0000-0000-0000-00000000000a') $$,
  '42501', null,
  'anon cannot issue tokens'
);

reset role;

-- ---------------------------------------------------------------------------
-- dealer_user of dealer A
-- ---------------------------------------------------------------------------

set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-0000-0000-0000-000000000001","role":"authenticated"}';

select results_eq(
  $$ select id from public.requests where id::text like 'cccccccc-%' $$,
  $$ values ('cccccccc-0000-0000-0000-00000000000a'::uuid) $$,
  'dealer sees only submitted requests of its own dealer (no drafts, no other dealers)'
);
select results_eq(
  $$ select request_id from public.photos where request_id::text like 'cccccccc-%' $$,
  $$ values ('cccccccc-0000-0000-0000-00000000000a'::uuid) $$,
  'dealer sees only photo rows of its own requests'
);
select results_eq(
  $$ select name from storage.objects where bucket_id = 'request-photos' and name like 'cccccccc-%' $$,
  $$ values ('cccccccc-0000-0000-0000-00000000000a/front.jpg'::text) $$,
  'dealer can only access stored photos of its own requests'
);
select results_eq(
  $$ select id from public.dealers where id::text like 'bbbbbbbb-%' $$,
  $$ values ('bbbbbbbb-0000-0000-0000-00000000000a'::uuid) $$,
  'dealer sees only its own dealer'
);
select results_eq(
  'select id from public.profiles',
  $$ values ('aaaaaaaa-0000-0000-0000-000000000001'::uuid) $$,
  'dealer sees only its own profile'
);
select throws_ok(
  $$ update public.requests set status = 'quoted' where id = 'cccccccc-0000-0000-0000-00000000000a' $$,
  '42501', null,
  'dealer cannot change status directly'
);

reset role;

-- ---------------------------------------------------------------------------
-- client (email OTP user without profile)
-- ---------------------------------------------------------------------------

set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-0000-0000-0000-000000000004","role":"authenticated"}';

select results_eq(
  $$ select id from public.requests where id::text like 'cccccccc-%' $$,
  $$ values ('cccccccc-0000-0000-0000-0000000000d1'::uuid) $$,
  'client sees only its own draft'
);
select results_eq(
  $$ update public.requests set contact_name = 'Nuevo nombre'
     where id = 'cccccccc-0000-0000-0000-0000000000d1' returning id $$,
  $$ values ('cccccccc-0000-0000-0000-0000000000d1'::uuid) $$,
  'client can edit form fields of its own draft'
);
select is_empty(
  $$ update public.requests set contact_name = 'Intruso'
     where id = 'cccccccc-0000-0000-0000-0000000000d2' returning id $$,
  'client cannot edit another client''s draft'
);
select throws_ok(
  $$ update public.requests set status = 'received' where id = 'cccccccc-0000-0000-0000-0000000000d1' $$,
  '42501', null,
  'client cannot change status directly'
);
select throws_ok(
  $$ insert into public.requests (status) values ('draft') $$,
  '42501', null,
  'client cannot insert requests directly'
);
select is_empty(
  $$ select id from public.dealers where id::text like 'bbbbbbbb-%' $$,
  'client cannot read dealers'
);
select is_empty('select id from public.profiles', 'client has no profile access');

reset role;

-- ---------------------------------------------------------------------------
-- admin
-- ---------------------------------------------------------------------------

set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-0000-0000-0000-000000000003","role":"authenticated"}';

select is(
  (select count(*)::int from public.requests where id::text like 'cccccccc-%'),
  4,
  'admin sees every request'
);
select is(
  (select count(*)::int from public.dealers where id::text like 'bbbbbbbb-%'),
  2,
  'admin sees every dealer'
);

reset role;

-- ---------------------------------------------------------------------------
-- Status history (RF-34): changes are recorded with the acting user
-- ---------------------------------------------------------------------------

set local request.jwt.claims = '{"sub":"aaaaaaaa-0000-0000-0000-000000000001","role":"authenticated"}';
update public.requests set status = 'quoted' where id = 'cccccccc-0000-0000-0000-00000000000a';

select results_eq(
  $$ select from_status, to_status, changed_by from public.status_events
     where request_id = 'cccccccc-0000-0000-0000-00000000000a' and to_status = 'quoted' $$,
  $$ values ('received'::public.request_status, 'quoted'::public.request_status,
             'aaaaaaaa-0000-0000-0000-000000000001'::uuid) $$,
  'RF-34: status change is recorded with from, to and user'
);

update public.requests set contact_name = 'Sin cambio de estado' where id = 'cccccccc-0000-0000-0000-00000000000a';
select is(
  (select count(*)::int from public.status_events where request_id = 'cccccccc-0000-0000-0000-00000000000a'),
  2,
  'updates without a status change do not record events'
);

select * from finish();
rollback;
