// Fictional catalog seed: 5 specialties, 2 clinics, 4 doctors,
// Mon-Fri 08:00-12:00 / 14:00-18:00 availability (30 min slots).
// Run with: npx tsx prisma/seed.ts (requires DATABASE_URL).

import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main(): Promise<void> {
  const specialtyNames = ['Cardiologia', 'Pediatria', 'Dermatologia', 'Oftalmologia', 'Ortopedia'];
  for (const nome of specialtyNames) {
    await prisma.specialty.upsert({ where: { nome }, update: {}, create: { nome } });
  }

  const careConnect = await prisma.clinic.upsert({
    where: { id: '00000000-0000-0000-0000-000000000001' },
    update: {},
    create: {
      id: '00000000-0000-0000-0000-000000000001',
      nome: 'Clinica CareConnect Central',
      endereco: 'Av. Paulista, 1000 - Bela Vista, Sao Paulo - SP',
    },
  });
  const vidaSaudavel = await prisma.clinic.upsert({
    where: { id: '00000000-0000-0000-0000-000000000002' },
    update: {},
    create: {
      id: '00000000-0000-0000-0000-000000000002',
      nome: 'Clinica Vida Saudavel',
      endereco: 'Rua das Flores, 200 - Centro, Sao Paulo - SP',
    },
  });

  const cardio = await prisma.specialty.findUniqueOrThrow({ where: { nome: 'Cardiologia' } });
  const pediatria = await prisma.specialty.findUniqueOrThrow({ where: { nome: 'Pediatria' } });
  const dermato = await prisma.specialty.findUniqueOrThrow({ where: { nome: 'Dermatologia' } });

  const doctors = [
    { nome: 'Dr. Carlos Eduardo Mendes', crm: 'CRM-SP 123456', specialtyId: cardio.id, rating: 4.9 },
    { nome: 'Dra. Ana Silva', crm: 'CRM-SP 234567', specialtyId: cardio.id, rating: 4.8 },
    { nome: 'Dra. Juliana Ferreira', crm: 'CRM-SP 345678', specialtyId: pediatria.id, rating: 4.9 },
    { nome: 'Dr. Roberto Almeida', crm: 'CRM-SP 456789', specialtyId: dermato.id, rating: 4.7 },
  ];

  for (const d of doctors) {
    const doctor = await prisma.doctor.upsert({
      where: { id: `seed-${d.nome}` },
      update: {},
      create: {
        id: `seed-${d.nome}`,
        nome: d.nome,
        crm: d.crm,
        specialtyId: d.specialtyId,
        rating: d.rating,
        clinics: { connect: [{ id: careConnect.id }] },
      },
    });

    await prisma.doctor.update({
      where: { id: doctor.id },
      data: { clinics: { connect: [{ id: vidaSaudavel.id }] } },
    });

    for (let dia = 1; dia <= 5; dia++) {
      await prisma.availability.deleteMany({ where: { doctorId: doctor.id, diaSemana: dia } });
      await prisma.availability.createMany({
        data: [
          { doctorId: doctor.id, diaSemana: dia, horaInicio: '08:00', horaFim: '12:00' },
          { doctorId: doctor.id, diaSemana: dia, horaInicio: '14:00', horaFim: '18:00' },
        ],
      });
    }
  }

  console.log('seed done');
}

main()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(() => {
    void prisma.$disconnect();
  });
