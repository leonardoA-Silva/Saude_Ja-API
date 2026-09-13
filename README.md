# SaudeJa API (Supabase backend)

Backend for the SaudeJa appointment app — MVP is patient-only, doctors are seeded catalog data.

## Stack
- Supabase Postgres + Auth + Storage + Edge Functions (Deno)
- SQL migrations in `supabase/migrations/`, seed in `supabase/seed.sql`

## Structure
```
api/
  supabase/
    migrations/0001_init.sql   -> tables, indexes, RLS
    seed.sql                   -> specialties, clinics, doctors, availability (fictional)
    functions/
      create-appointment/      -> slot validation + booking (S3)
      send-reminders/          -> 24h / 2h push reminders (S4)
```

## Setup
1. Create a project at https://supabase.com/dashboard
2. SQL Editor > run `supabase/migrations/0001_init.sql`, then `supabase/seed.sql`
3. Auth > enable Email provider
4. Copy `.env.example` to `.env` (never commit `.env`) and fill the keys
5. Paste `EXPO_PUBLIC_SUPABASE_URL` + anon key into `mobile/.env`

## Rules
- Catalog tables (`specialties`, `clinics`, `doctors`, `doctor_clinics`, `doctor_availability`): public read-only.
- `profiles` / `appointments` / `notifications`: RLS scoped to `auth.uid()`.
- `service_role` key is server-only — only Edge Functions use it.
- `unique (doctor_id, data_hora)` is the double-booking guard.

## Roadmap
- S1: project + migration applied, Auth wired in mobile
- S3: `create-appointment` implemented + deployed
- S4: `send-reminders` + pg_cron schedule
