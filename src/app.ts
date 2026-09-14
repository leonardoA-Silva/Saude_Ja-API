import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';
import { errorHandler } from './middlewares/errorHandler';
import { notFound } from './middlewares/notFound';
import { appointmentsRouter } from './routes/appointments.routes';
import { authRouter } from './routes/auth.routes';
import { doctorsRouter } from './routes/doctors.routes';
import { healthRouter } from './routes/health.routes';
import { specialtiesRouter } from './routes/specialties.routes';

export function createApp(): express.Express {
  const app = express();

  app.use(helmet());
  app.use(cors());
  app.use(express.json());
  app.use(morgan('dev'));

  app.use('/health', healthRouter);
  app.use('/auth', authRouter);
  app.use('/specialties', specialtiesRouter);
  app.use('/doctors', doctorsRouter);
  app.use('/appointments', appointmentsRouter);

  app.use(notFound);
  app.use(errorHandler);

  return app;
}
