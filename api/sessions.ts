/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * API Route: /api/sessions
 * Purpose: Create a new game session.
 */

import type { VercelRequest, VercelResponse } from '@vercel/node';
import { neon } from '@neondatabase/serverless';

function setCors(res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  setCors(res);
  if (req.method === 'OPTIONS') return res.status(204).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const sql = neon(process.env.DATABASE_URL!);

  try {
    const { players, position, smallBlind, bigBlind, buyIn } = req.body;

    const [session] = await sql`
      INSERT INTO sessions (players, position, small_blind, big_blind, buy_in)
      VALUES (${players}, ${position}, ${smallBlind}, ${bigBlind}, ${buyIn ?? null})
      RETURNING id
    `;

    return res.status(201).json({ id: session.id });
  } catch (e) {
    console.error('[sessions] error:', e);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
