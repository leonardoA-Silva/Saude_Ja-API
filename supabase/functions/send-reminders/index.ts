// SaudeJa Edge Function: send-reminders (S4 stub).
// Triggered by pg_cron / scheduled workflow. Finds appointments in the
// next 24h / 2h without a matching notification row, sends Expo Push via
// profiles.expo_push_token and records into notifications.
// Deploy in S4 with: supabase functions deploy send-reminders

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

serve(async (_req: Request) => {
  // S4: query due appointments, push, insert notifications.
  return new Response(JSON.stringify({ error: 'not implemented (S4)' }), {
    status: 501,
    headers: { 'Content-Type': 'application/json' },
  });
});
