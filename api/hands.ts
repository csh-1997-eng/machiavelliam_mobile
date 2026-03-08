/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * API Route: /api/hands
 * Purpose: POST to create a hand, PATCH to update with final outcome.
 */

import type { VercelRequest, VercelResponse } from '@vercel/node';
import { neon } from '@neondatabase/serverless';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, PATCH, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method === 'OPTIONS') return res.status(204).setHeaders(corsHeaders).end();

  const sql = neon(process.env.DATABASE_URL!);

  try {
    if (req.method === 'POST') {
      const { sessionId, holeCards } = req.body;

      const [hand] = await sql`
        INSERT INTO hands (session_id, hole_cards, community_cards)
        VALUES (${sessionId}, ${holeCards}, ${[]})
        RETURNING id
      `;

      return res.status(201).setHeaders(corsHeaders).json({ id: hand.id });
    }

    if (req.method === 'PATCH') {
      const { handId, communityCards, finalHand, handStrength, phaseReached } = req.body;

      await sql`
        UPDATE hands
        SET community_cards = ${communityCards},
            final_hand      = ${finalHand},
            hand_strength   = ${handStrength},
            phase_reached   = ${phaseReached}
        WHERE id = ${handId}
      `;

      return res.status(200).setHeaders(corsHeaders).json({ success: true });
    }

    return res.status(405).setHeaders(corsHeaders).json({ error: 'Method not allowed' });
  } catch (e) {
    console.error('[hands] error:', e);
    return res.status(500).setHeaders(corsHeaders).json({ error: 'Internal server error' });
  }
}
