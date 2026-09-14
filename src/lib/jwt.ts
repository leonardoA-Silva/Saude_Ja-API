import jwt from 'jsonwebtoken';

function getSecret(): string {
  const secret = process.env.JWT_SECRET;
  if (!secret) throw new Error('JWT_SECRET is not set');
  return secret;
}

export function signAccessToken(userId: string): string {
  return jwt.sign({}, getSecret(), {
    subject: userId,
    expiresIn: process.env.JWT_EXPIRES_IN ?? '7d',
  } as jwt.SignOptions);
}

export function verifyAccessToken(token: string): { sub: string } {
  return jwt.verify(token, getSecret()) as { sub: string };
}
