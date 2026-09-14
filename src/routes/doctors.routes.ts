import { Router } from 'express';

// S2: GET /?specialtyId= (doctors by specialty), GET /:id (detail +
// availability slots). S3: slot computation lives here.
export const doctorsRouter = Router();

doctorsRouter.all('*', (_req, res) => {
  res.status(501).json({ error: 'not implemented' });
});
