/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * API Route: /api/insights
 * Purpose: Generate Machiavellian poker coaching advice via OpenAI.
 *          Receives hand state + player's action, returns nuanced coaching.
 */

import type { VercelRequest, VercelResponse } from '@vercel/node';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

interface RequestBody {
  phase: string;
  settings: {
    players: number;
    position: string;
    smallBlind: number;
    bigBlind: number;
  };
  userHoleCards: string[];
  communityCards: string[];
  evaluation?: string | null;
  handStrengthPercent: number;
  playerAction?: { action: string; amount?: number } | null;
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  if (req.method === 'OPTIONS') return res.status(204).setHeaders(corsHeaders).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const openAiKey = process.env.OPENAI_API_KEY;
  if (!openAiKey) return res.status(500).json({ error: 'OPENAI_API_KEY not configured' });

  const body = req.body as RequestBody;
  const { phase, settings, userHoleCards, communityCards, evaluation, handStrengthPercent, playerAction } = body;

  const actionContext = playerAction
    ? `Player's action this street: ${playerAction.action.toUpperCase()}${playerAction.amount ? ` $${playerAction.amount}` : ''}.`
    : 'Player has not yet acted this street.';

  const prompt = `You are a world-class poker coach with the strategic mind of Machiavelli — analytical, ruthless, and deeply psychological.

Game State:
- Phase: ${phase}
- Players: ${settings.players}
- Hero position: ${settings.position}
- Blinds: $${settings.smallBlind}/$${settings.bigBlind}
- Hole cards: ${userHoleCards.join(', ') || 'N/A'}
- Community cards: ${communityCards.join(', ') || 'None'}
- Current hand: ${evaluation ?? 'N/A'}
- Raw hand strength: ${Math.round(handStrengthPercent)}%
- ${actionContext}

Coaching guidelines:
- Go beyond hand strength — think in ranges, equity, and pot dynamics
- Factor in position ruthlessly: late position is power, early position is constraint
- Address the meta-game: table image, opponent tendencies, exploitative vs. GTO play
- If the player acted, critique or validate their decision with specific reasoning
- Call out bluff spots, value bet sizing, trapping opportunities, and fold equity
- Be direct and decisive — no hedging. Tell them what to do and exactly why.
- Keep it to 4-6 tight, high-signal bullets. No padding.`;

  try {
    const openAiRes = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${openAiKey}`,
      },
      body: JSON.stringify({
        model: 'gpt-4.1-mini',
        input: prompt,
        max_output_tokens: 500,
        temperature: 0.7,
      }),
    });

    if (!openAiRes.ok) {
      const err = await openAiRes.text();
      console.error('[insights] OpenAI error:', err);
      return res.status(502).setHeaders(corsHeaders).json({ error: 'OpenAI error' });
    }

    const data = await openAiRes.json();
    const insights =
      data.output_text ??
      data.choices?.[0]?.message?.content?.[0]?.text ??
      data.choices?.[0]?.message?.content ??
      data.choices?.[0]?.text ??
      JSON.stringify(data);

    return res.status(200).setHeaders(corsHeaders).json({ insights });
  } catch (e) {
    console.error('[insights] error:', e);
    return res.status(500).setHeaders(corsHeaders).json({ error: 'Internal server error' });
  }
}
