import { Router } from 'express';

// S1: POST /register, POST /login, GET /me (requireAuth).
export const authRouter = Router();

authRouter.all('*', (_req, res) => {
  res.status(501).json({ error: 'not implemented' });
});
