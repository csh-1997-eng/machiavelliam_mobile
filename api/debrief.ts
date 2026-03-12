/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * API Route: /api/debrief
 * Purpose: Session retrospective coaching. Joins hand/action data from Neon,
 *          builds a pattern-focused debrief prompt, sends to OpenAI.
 */

import type { VercelRequest, VercelResponse } from '@vercel/node';
import { neon } from '@neondatabase/serverless';

function setCors(res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}

interface HandRecord {
  hand_id: string;
  hole_cards: string;
  community_cards: string | null;
  final_hand: string | null;
  phase_reached: string | null;
  action: string | null;
  phase: string | null;
}

function buildDebriefPrompt(sessionSummary: string, handCount: number): string {
  return `You are a world-class poker coach with the strategic mind of Machiavelli — analytical, ruthless, and deeply psychological. A player just finished a session and wants a debrief. Analyze the patterns in their decision history. Be specific and direct — name the leaks, name the fixes. Use 4-6 tight bullets, then one closing directive sentence.

Session summary (${handCount} hand${handCount === 1 ? '' : 's'}):
${sessionSummary}

Debrief focus:
- Identify recurring decision patterns — what did they do consistently (good or bad)?
- Where did they leave money on the table? (folded too much, called too wide, sized poorly)
- What was their aggression profile? Too passive, too loose, balanced?
- Name the single biggest leak from this session and the fix
- If they played well, tell them specifically what they did right and why it works
- Close with one sharp directive for their next session`;
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  setCors(res);
  if (req.method === 'OPTIONS') return res.status(204).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const openAiKey = process.env.OPENAI_API_KEY;
  if (!openAiKey) return res.status(500).json({ error: 'OPENAI_API_KEY not configured' });

  const { sessionId } = req.body as { sessionId?: string };
  if (!sessionId) return res.status(400).json({ error: 'sessionId required' });

  const sql = neon(process.env.DATABASE_URL!);

  try {
    const rows = await sql<HandRecord[]>`
      SELECT
        h.id AS hand_id,
        h.hole_cards,
        h.community_cards,
        h.final_hand,
        h.phase_reached,
        pa.action,
        pa.phase
      FROM hands h
      LEFT JOIN player_actions pa ON pa.hand_id = h.id
      WHERE h.session_id = ${sessionId}
      ORDER BY h.created_at ASC, pa.created_at ASC
    `;

    if (!rows.length) {
      return res.status(404).json({ error: 'No hands found for this session' });
    }

    // Group by hand, sample if > 30 hands
    const handMap = new Map<string, HandRecord[]>();
    for (const row of rows) {
      if (!handMap.has(row.hand_id)) handMap.set(row.hand_id, []);
      handMap.get(row.hand_id)!.push(row);
    }

    let hands = Array.from(handMap.entries());
    if (hands.length > 30) {
      // Sample every other hand to stay within token budget
      hands = hands.filter((_, i) => i % 2 === 0);
    }

    const handCount = handMap.size;
    const lines: string[] = [];

    for (const [, actions] of hands) {
      const first = actions[0];
      const holeCards = first.hole_cards ?? 'unknown';
      const board = first.community_cards ?? 'none';
      const finalHand = first.final_hand ?? 'N/A';
      const phaseReached = first.phase_reached ?? 'preflop';

      const actionStr = actions
        .filter(a => a.action)
        .map(a => `${a.phase?.toUpperCase()}: ${a.action?.toUpperCase()}`)
        .join(' → ') || 'no actions recorded';

      lines.push(`Hand: ${holeCards} | Board: ${board} | Result: ${finalHand} | Reached: ${phaseReached} | Actions: ${actionStr}`);
    }

    const sessionSummary = lines.join('\n');
    const prompt = buildDebriefPrompt(sessionSummary, handCount);

    const openAiRes = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${openAiKey}`,
      },
      body: JSON.stringify({
        model: 'gpt-4.1-mini',
        input: prompt,
        max_output_tokens: 600,
        temperature: 0.7,
      }),
    });

    if (!openAiRes.ok) {
      const err = await openAiRes.text();
      console.error('[debrief] OpenAI error:', err);
      return res.status(502).json({ error: 'OpenAI error' });
    }

    const data = await openAiRes.json();
    const report =
      data.output_text ??
      data.choices?.[0]?.message?.content?.[0]?.text ??
      data.choices?.[0]?.message?.content ??
      data.choices?.[0]?.text ??
      JSON.stringify(data);

    return res.status(200).json({ report });
  } catch (e) {
    console.error('[debrief] error:', e);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
