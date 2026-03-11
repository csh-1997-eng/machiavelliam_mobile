/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * API Route: /api/profile
 * Purpose: Aggregate hand history from Neon → compute VPIP, PFR, aggression factor,
 *          positional tendencies, leaks, and a summary string for AI injection.
 */

import type { VercelRequest, VercelResponse } from '@vercel/node';
import { neon } from '@neondatabase/serverless';

function setCors(res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}

function classifyStyle(vpip: number, pfr: number): string {
  if (vpip > 35 && pfr > 25) return 'Loose-aggressive (LAG)';
  if (vpip > 35 && pfr <= 25) return 'Loose-passive';
  if (vpip <= 20 && pfr > 15) return 'Tight-aggressive (TAG)';
  if (vpip <= 20 && pfr <= 15) return 'Tight-passive (nit)';
  return 'Mixed';
}

function detectLeaks(vpip: number, pfr: number, af: number): string[] {
  const leaks: string[] = [];
  if (vpip > 40) leaks.push(`Playing too many hands preflop (VPIP ${vpip}%)`);
  if (vpip < 15) leaks.push(`Too tight preflop — missing value spots (VPIP ${vpip}%)`);
  if (pfr < vpip * 0.4) leaks.push(`Not raising enough preflop — calling too much (PFR ${pfr}% vs VPIP ${vpip}%)`);
  if (af < 1.0) leaks.push(`Overall passive — not betting/raising enough (AF ${af})`);
  if (af > 4.0) leaks.push(`Overly aggressive — polarizing range too wide (AF ${af})`);
  return leaks;
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  setCors(res);
  if (req.method === 'OPTIONS') return res.status(204).end();
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const sql = neon(process.env.DATABASE_URL!);

  try {
    // Aggregate totals: hands played, VPIP, PFR, aggression counts
    const [totals] = await sql`
      SELECT
        COUNT(DISTINCT h.id)::int AS total_hands,
        COUNT(DISTINCT CASE WHEN pa.phase = 'preflop' AND pa.action IN ('call','bet','raise') THEN pa.hand_id END)::int AS vpip_hands,
        COUNT(DISTINCT CASE WHEN pa.phase = 'preflop' AND pa.action IN ('bet','raise') THEN pa.hand_id END)::int AS pfr_hands,
        COUNT(CASE WHEN pa.action IN ('bet','raise') THEN 1 END)::int AS aggressive_actions,
        COUNT(CASE WHEN pa.action = 'call' THEN 1 END)::int AS passive_actions
      FROM hands h
      LEFT JOIN player_actions pa ON pa.hand_id = h.id
    `;

    // Breakdown by position
    const positional = await sql`
      SELECT
        s.position,
        COUNT(DISTINCT h.id)::int AS hands,
        COUNT(DISTINCT CASE WHEN pa.phase = 'preflop' AND pa.action IN ('call','bet','raise') THEN pa.hand_id END)::int AS vpip_hands,
        COUNT(DISTINCT CASE WHEN pa.phase = 'preflop' AND pa.action IN ('bet','raise') THEN pa.hand_id END)::int AS pfr_hands
      FROM sessions s
      JOIN hands h ON h.session_id = s.id
      LEFT JOIN player_actions pa ON pa.hand_id = h.id
      GROUP BY s.position
      ORDER BY COUNT(DISTINCT h.id) DESC
    `;

    const totalHands: number = totals.total_hands ?? 0;
    const vpipHands: number = totals.vpip_hands ?? 0;
    const pfrHands: number = totals.pfr_hands ?? 0;
    const aggressiveActions: number = totals.aggressive_actions ?? 0;
    const passiveActions: number = totals.passive_actions ?? 0;

    const vpip = totalHands > 0 ? Math.round((vpipHands / totalHands) * 100) : 0;
    const pfr = totalHands > 0 ? Math.round((pfrHands / totalHands) * 100) : 0;
    const af = passiveActions > 0 ? Math.round((aggressiveActions / passiveActions) * 10) / 10 : aggressiveActions > 0 ? 99 : 0;

    const style = classifyStyle(vpip, pfr);
    const leaks = detectLeaks(vpip, pfr, af);

    const byPosition = positional.map((row) => ({
      position: row.position,
      hands: row.hands,
      vpip: row.hands > 0 ? Math.round((row.vpip_hands / row.hands) * 100) : 0,
      pfr: row.hands > 0 ? Math.round((row.pfr_hands / row.hands) * 100) : 0,
    }));

    const summary = totalHands < 5
      ? null
      : `Player profile (${totalHands} hands): VPIP ${vpip}%, PFR ${pfr}%, Aggression Factor ${af}. Style: ${style}.${leaks.length > 0 ? ` Known leaks: ${leaks.join('; ')}.` : ''}`;

    return res.status(200).json({
      totalHands,
      vpip,
      pfr,
      aggressionFactor: af,
      style,
      leaks,
      byPosition,
      summary,
    });
  } catch (e) {
    console.error('[profile] error:', e);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
