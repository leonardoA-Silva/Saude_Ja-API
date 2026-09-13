-- SaudeJa MVP (S0): seed for the mocked-doctor catalog.
-- Run AFTER 0001_init.sql via Supabase Dashboard > SQL Editor.
-- All data is fictional. Timezone: America/Sao_Paulo display, timestamptz storage.

-- ---------------------------------------------------------------- specialties
insert into public.specialties (nome, icone) values
  ('Cardiologia', 'heart'),
  ('Pediatria', 'baby'),
  ('Dermatologia', 'sparkles'),
  ('Oftalmologia', 'eye'),
  ('Ortopedia', 'bone')
on conflict (nome) do nothing;

-- ---------------------------------------------------------------- clinics
insert into public.clinics (nome, endereco) values
  ('Clinica CareConnect Central', 'Av. Paulista, 1000 - Bela Vista, Sao Paulo - SP'),
  ('Clinica Vida Saudavel', 'Rua das Flores, 200 - Centro, Sao Paulo - SP')
on conflict do nothing;

-- ---------------------------------------------------------------- doctors
insert into public.doctors (nome, crm, specialty_id, rating) values
  ('Dr. Carlos Eduardo Mendes', 'CRM-SP 123456',
    (select id from public.specialties where nome = 'Cardiologia'), 4.9),
  ('Dra. Ana Silva', 'CRM-SP 234567',
    (select id from public.specialties where nome = 'Cardiologia'), 4.8),
  ('Dra. Juliana Ferreira', 'CRM-SP 345678',
    (select id from public.specialties where nome = 'Pediatria'), 4.9),
  ('Dr. Roberto Almeida', 'CRM-SP 456789',
    (select id from public.specialties where nome = 'Dermatologia'), 4.7)
on conflict do nothing;

-- ---------------------------------------------------------------- links
insert into public.doctor_clinics (doctor_id, clinic_id)
select d.id, c.id
from public.doctors d
cross join public.clinics c
where c.nome = 'Clinica CareConnect Central'
on conflict do nothing;

insert into public.doctor_clinics (doctor_id, clinic_id)
select d.id, c.id
from public.doctors d
cross join public.clinics c
where d.nome = 'Dr. Carlos Eduardo Mendes'
  and c.nome = 'Clinica Vida Saudavel'
on conflict do nothing;

-- ---------------------------------------------------------------- availability
-- Mon-Fri (1-5): 08:00-12:00 and 14:00-18:00, 30 min slots.
insert into public.doctor_availability (doctor_id, dia_semana, hora_inicio, hora_fim, intervalo_min)
select d.id, gs.dia, '08:00'::time, '12:00'::time, 30
from public.doctors d
cross join generate_series(1, 5) as gs(dia)
where not exists (
  select 1 from public.doctor_availability a
  where a.doctor_id = d.id and a.dia_semana = gs.dia and a.hora_inicio = '08:00'::time
);

insert into public.doctor_availability (doctor_id, dia_semana, hora_inicio, hora_fim, intervalo_min)
select d.id, gs.dia, '14:00'::time, '18:00'::time, 30
from public.doctors d
cross join generate_series(1, 5) as gs(dia)
where not exists (
  select 1 from public.doctor_availability a
  where a.doctor_id = d.id and a.dia_semana = gs.dia and a.hora_inicio = '14:00'::time
);
