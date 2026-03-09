/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * API Route: /api/actions
 * Purpose: Record a player's betting decision at a given phase.
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
    const { handId, phase, action, amount } = req.body;

    await sql`
      INSERT INTO player_actions (hand_id, phase, action, amount)
      VALUES (${handId}, ${phase}, ${action}, ${amount ?? null})
    `;

    return res.status(201).json({ success: true });
  } catch (e) {
    console.error('[actions] error:', e);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
