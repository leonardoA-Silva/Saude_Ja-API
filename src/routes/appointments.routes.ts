import { Router } from 'express';

// S3/S4 (all requireAuth): GET / (my appointments), POST / (book a slot),
// PATCH /:id/cancel, PATCH /:id/reschedule.
export const appointmentsRouter = Router();

appointmentsRouter.all('*', (_req, res) => {
  res.status(501).json({ error: 'not implemented' });
});
