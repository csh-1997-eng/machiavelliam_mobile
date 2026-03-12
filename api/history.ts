/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * API Route: /api/history
 * Purpose: GET paginated hand history for a session.
 *          Returns 20 hands per page with actions nested per hand.
 */

import type { VercelRequest, VercelResponse } from '@vercel/node';
import { neon } from '@neondatabase/serverless';

function setCors(res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}

const PAGE_SIZE = 20;

export default async function handler(req: VercelRequest, res: VercelResponse) {
  setCors(res);
  if (req.method === 'OPTIONS') return res.status(204).end();
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const { sessionId, page } = req.query;
  if (!sessionId || typeof sessionId !== 'string') {
    return res.status(400).json({ error: 'sessionId required' });
  }

  const pageNum = Math.max(0, parseInt(String(page ?? '0'), 10) || 0);
  const offset = pageNum * PAGE_SIZE;

  const sql = neon(process.env.DATABASE_URL!);

  try {
    // Fetch hands with pagination
    const hands = await sql`
      SELECT
        h.id,
        h.hole_cards,
        h.community_cards,
        h.final_hand,
        h.hand_strength,
        h.phase_reached,
        h.created_at
      FROM hands h
      WHERE h.session_id = ${sessionId}
      ORDER BY h.created_at DESC
      LIMIT ${PAGE_SIZE} OFFSET ${offset}
    `;

    if (!hands.length) {
      return res.status(200).json({ hands: [], hasMore: false });
    }

    const handIds = hands.map(h => h.id);

    // Fetch all actions for these hands in one query
    const actions = await sql`
      SELECT hand_id, phase, action, amount, created_at
      FROM player_actions
      WHERE hand_id = ANY(${handIds}::uuid[])
      ORDER BY created_at ASC
    `;

    // Group actions by hand
    const actionMap = new Map<string, typeof actions>();
    for (const action of actions) {
      if (!actionMap.has(action.hand_id)) actionMap.set(action.hand_id, []);
      actionMap.get(action.hand_id)!.push(action);
    }

    const result = hands.map(h => ({
      id: h.id,
      holeCards: h.hole_cards,
      communityCards: h.community_cards ?? [],
      finalHand: h.final_hand,
      handStrength: h.hand_strength,
      phaseReached: h.phase_reached,
      createdAt: h.created_at,
      actions: (actionMap.get(h.id) ?? []).map(a => ({
        phase: a.phase,
        action: a.action,
        amount: a.amount,
      })),
    }));

    // Check if there are more pages
    const [{ count }] = await sql`
      SELECT COUNT(*)::int AS count FROM hands WHERE session_id = ${sessionId}
    `;

    return res.status(200).json({
      hands: result,
      hasMore: offset + PAGE_SIZE < count,
      total: count,
    });
  } catch (e) {
    console.error('[history] error:', e);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
