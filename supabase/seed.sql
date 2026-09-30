-- Local development data only. Never run against the cloud project.
-- The real dealer, branch, catalog and users are loaded by hand (RF-29, RF-30).

-- Dealer and its single branch
insert into public.dealers (id, name, legal_name, timezone) values
  ('11111111-1111-1111-1111-111111111111', 'Automotora Demo', 'Automotora Demo S.A.', 'America/Montevideo');

insert into public.branches (dealer_id, name, address, opening_hours, phone, email, visit_documents) values
  ('11111111-1111-1111-1111-111111111111', 'Casa central', 'Av. Siempre Viva 1234', 'Lunes a viernes de 9 a 18',
   '+598 2000 0000', 'contacto@example.com', 'Libreta de propiedad y cédula de identidad');

-- Sample catalog (RF-03)
insert into public.vehicle_catalog (brand, model) values
  ('Chevrolet', 'Onix'),
  ('Fiat', 'Cronos'),
  ('Hyundai', 'HB20'),
  ('Toyota', 'Corolla'),
  ('Toyota', 'Hilux'),
  ('Volkswagen', 'Amarok'),
  ('Volkswagen', 'Gol');

-- Staff users (password for both: local-dev-password)
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, email_change, email_change_token_new, recovery_token
)
select
  '00000000-0000-0000-0000-000000000000', u.id, 'authenticated', 'authenticated', u.email,
  extensions.crypt('local-dev-password', extensions.gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}', '{}', now(), now(),
  '', '', '', ''
from (values
  ('22222222-2222-2222-2222-222222222222'::uuid, 'dealer@example.com'),
  ('33333333-3333-3333-3333-333333333333'::uuid, 'admin@example.com')
) as u (id, email);

insert into auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
select gen_random_uuid(), u.id, u.id::text,
  jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
  'email', now(), now(), now()
from auth.users u
where u.id in ('22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333');

insert into public.profiles (id, role, dealer_id, full_name) values
  ('22222222-2222-2222-2222-222222222222', 'dealer_user', '11111111-1111-1111-1111-111111111111', 'Usuario Automotora'),
  ('33333333-3333-3333-3333-333333333333', 'admin', null, 'Administrador');

-- A submitted request. Tracking link: /seguimiento#demo-local-token-00000000000000000000000000
insert into public.requests (
  id, status, dealer_id, contact_name, contact_phone, contact_email,
  vehicle_catalog_id, vehicle_version, vehicle_year, mileage_km,
  condition, consent_at, consent_version, submitted_at, quote_due_at
) values (
  '44444444-4444-4444-4444-444444444444', 'received', '11111111-1111-1111-1111-111111111111',
  'Cliente Demo', '+598 99 000 000', 'cliente@example.com',
  (select id from public.vehicle_catalog where brand = 'Toyota' and model = 'Corolla'), 'XEi 2.0', 2019, 85000,
  'good', now(), 'v0-local', now(), now() + interval '4 hours'
);

insert into public.request_tokens (request_id, token_hash) values
  ('44444444-4444-4444-4444-444444444444',
   extensions.digest('demo-local-token-00000000000000000000000000', 'sha256'));
