// SaudeJa Edge Function: create-appointment (S3 stub).
// Validates the requested slot against doctor_availability + existing
// appointments, then inserts a 'pendente' appointment as the patient.
// Deploy in S3 with: supabase functions deploy create-appointment

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'method not allowed' }), {
      status: 405,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }

  // S3: parse { doctor_id, clinic_id, data_hora }, verify JWT, check slot,
  // insert appointment + confirmacao notification.
  return new Response(JSON.stringify({ error: 'not implemented (S3)' }), {
    status: 501,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });
});
