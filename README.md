# SaudeJa API (Express backend)

Backend for the SaudeJa appointment app — MVP is patient-only, doctors are seeded catalog data.

## Stack
- Node + Express 4 + TypeScript
- Prisma + PostgreSQL
- JWT auth (bcrypt + jsonwebtoken), zod validation

## Structure
```
api/
  prisma/
    schema.prisma   -> Profile, Specialty, Clinic, Doctor, Availability, Appointment
    seed.ts         -> fictional catalog (npx tsx prisma/seed.ts)
  src/
    server.ts       -> listen entry
    app.ts          -> middlewares + route mounting
    routes/         -> health (live), auth/specialties/doctors/appointments (S1-S4)
    middlewares/    -> requireAuth (JWT), notFound, errorHandler
    lib/            -> prisma, jwt, password
    utils/          -> AppError
```

## Setup
1. `npm install`
2. Copy `.env.example` to `.env` and set `DATABASE_URL` + `JWT_SECRET`
3. `npx prisma migrate dev --name init` then `npx tsx prisma/seed.ts`
4. `npm run dev` -> `GET http://localhost:3000/health`

## Contract (mobile)
- `POST /auth/register` `{ nome, cpf, email, telefone, senha }` -> `{ token, user }`
- `POST /auth/login` `{ cpfOuEmail, senha }` -> `{ token, user }`
- `GET /specialties`, `GET /doctors?specialtyId=`, `GET /doctors/:id`
- `GET /appointments` (auth), `POST /appointments` (auth), `PATCH /appointments/:id/cancel|reschedule` (auth)

## Rules
- `@@unique([doctorId, startsAt])` is the double-booking guard.
- All `/appointments` routes require `Authorization: Bearer <token>`.
- Times stored as UTC, displayed as America/Sao_Paulo in mobile.

## Roadmap
- S1: auth endpoints + JWT in mobile
- S2: catalog endpoints
- S3: booking with slot validation
- S4: cancel/reschedule + reminders
