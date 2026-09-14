import { Router } from 'express';

// S2: GET / (list specialties for the search grid).
export const specialtiesRouter = Router();

specialtiesRouter.all('*', (_req, res) => {
  res.status(501).json({ error: 'not implemented' });
});
