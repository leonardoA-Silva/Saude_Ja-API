-- SaudeJa MVP (S0): core schema for the patient-only flow.
-- Apply via Supabase Dashboard > SQL Editor or `supabase db push`.
-- Follows the plan in PLANO.md: catalog is publicly readable,
-- patients can only touch their own rows (RLS).

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------- profiles
-- 1:1 with auth.users. Created by the mobile app right after sign-up
-- (cpf is required, so no auto-insert trigger here).

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nome text not null,
  cpf text unique not null,
  telefone text,
  avatar_url text,
  convenio text,
  expo_push_token text,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------- catalog

create table public.specialties (
  id uuid primary key default gen_random_uuid(),
  nome text unique not null,
  icone text
);

create table public.clinics (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  endereco text not null,
  created_at timestamptz not null default now()
);

create table public.doctors (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  crm text,
  specialty_id uuid references public.specialties (id),
  foto_url text,
  rating numeric(2, 1) not null default 5.0,
  ativo boolean not null default true
);

create table public.doctor_clinics (
  doctor_id uuid not null references public.doctors (id) on delete cascade,
  clinic_id uuid not null references public.clinics (id) on delete cascade,
  primary key (doctor_id, clinic_id)
);

create table public.doctor_availability (
  id uuid primary key default gen_random_uuid(),
  doctor_id uuid not null references public.doctors (id) on delete cascade,
  dia_semana int not null check (dia_semana between 0 and 6), -- 0 = Sunday
  hora_inicio time not null,
  hora_fim time not null,
  intervalo_min int not null default 30,
  check (hora_fim > hora_inicio)
);

-- ---------------------------------------------------------------- booking

create table public.appointments (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.profiles (id) on delete cascade,
  doctor_id uuid not null references public.doctors (id),
  clinic_id uuid not null references public.clinics (id),
  data_hora timestamptz not null,
  duracao_min int not null default 30,
  status text not null default 'pendente'
    check (status in ('pendente', 'confirmada', 'cancelada', 'realizada', 'faltou')),
  motivo text,
  created_at timestamptz not null default now(),
  unique (doctor_id, data_hora) -- prevents double-booking at the DB level
);

create index appointments_patient_idx on public.appointments (patient_id, data_hora);
create index appointments_doctor_idx on public.appointments (doctor_id, data_hora);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  appointment_id uuid references public.appointments (id) on delete cascade,
  tipo text not null, -- confirmacao, cancelamento, lembrete_24h, lembrete_2h
  enviada_em timestamptz not null default now()
);

create index notifications_user_idx on public.notifications (user_id);

-- ---------------------------------------------------------------- RLS

alter table public.profiles enable row level security;
alter table public.specialties enable row level security;
alter table public.clinics enable row level security;
alter table public.doctors enable row level security;
alter table public.doctor_clinics enable row level security;
alter table public.doctor_availability enable row level security;
alter table public.appointments enable row level security;
alter table public.notifications enable row level security;

-- Catalog: publicly readable (search works even before login).
create policy "catalog public read" on public.specialties
  for select to anon, authenticated using (true);
create policy "catalog public read" on public.clinics
  for select to anon, authenticated using (true);
create policy "catalog public read" on public.doctors
  for select to anon, authenticated using (true);
create policy "catalog public read" on public.doctor_clinics
  for select to anon, authenticated using (true);
create policy "catalog public read" on public.doctor_availability
  for select to anon, authenticated using (true);

-- Profiles: users manage only their own row.
create policy "own profile read" on public.profiles
  for select to authenticated using (auth.uid() = id);
create policy "own profile insert" on public.profiles
  for insert to authenticated with check (auth.uid() = id);
create policy "own profile update" on public.profiles
  for update to authenticated
  using (auth.uid() = id) with check (auth.uid() = id);

-- Appointments: patients see/create/cancel only their own.
create policy "own appointments read" on public.appointments
  for select to authenticated using (auth.uid() = patient_id);
create policy "own appointments insert" on public.appointments
  for insert to authenticated with check (auth.uid() = patient_id);
create policy "own appointments update" on public.appointments
  for update to authenticated
  using (auth.uid() = patient_id) with check (auth.uid() = patient_id);

-- Notifications: read-only for the owner (written by Edge Functions).
create policy "own notifications read" on public.notifications
  for select to authenticated using (auth.uid() = user_id);
