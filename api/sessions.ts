/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * API Route: /api/sessions
 * Purpose: Create a new game session in Neon.
 */

import type { VercelRequest, VercelResponse } from '@vercel/node';
import { neon } from '@neondatabase/serverless';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method === 'OPTIONS') return res.status(204).setHeaders(corsHeaders).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const sql = neon(process.env.DATABASE_URL!);

  try {
    const { players, position, smallBlind, bigBlind } = req.body;

    const [session] = await sql`
      INSERT INTO sessions (players, position, small_blind, big_blind)
      VALUES (${players}, ${position}, ${smallBlind}, ${bigBlind})
      RETURNING id
    `;

    return res.status(201).setHeaders(corsHeaders).json({ id: session.id });
  } catch (e) {
    console.error('[sessions] error:', e);
    return res.status(500).setHeaders(corsHeaders).json({ error: 'Internal server error' });
  }
}
