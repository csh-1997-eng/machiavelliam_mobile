/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * API Route: /api/insights
 * Purpose: Generate Machiavellian poker coaching advice via OpenAI.
 *          Receives hand state + player's action, returns nuanced coaching.
 */

import type { VercelRequest, VercelResponse } from '@vercel/node';

function setCors(res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}

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
  question?: string | null;
  profileSummary?: string | null;
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  setCors(res);
  if (req.method === 'OPTIONS') return res.status(204).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const openAiKey = process.env.OPENAI_API_KEY;
  if (!openAiKey) return res.status(500).json({ error: 'OPENAI_API_KEY not configured' });

  const body = req.body as RequestBody;
  const { phase, settings, userHoleCards, communityCards, evaluation, handStrengthPercent, playerAction, question, profileSummary } = body;

  const actionContext = playerAction
    ? `Player's action this street: ${playerAction.action.toUpperCase()}${playerAction.amount ? ` $${playerAction.amount}` : ''}.`
    : 'Player has not yet acted this street.';

  const gameContext = `Current hand:
- Phase: ${phase}
- Players: ${settings.players}, Hero position: ${settings.position}
- Blinds: $${settings.smallBlind}/$${settings.bigBlind}
- Hole cards: ${userHoleCards.join(', ') || 'N/A'}
- Community cards: ${communityCards.join(', ') || 'None'}
- Hand: ${evaluation ?? 'N/A'} (${Math.round(handStrengthPercent)}% raw strength)
- ${actionContext}${profileSummary ? `\n- ${profileSummary}` : ''}`;

  const prompt = question
    ? `You are a world-class poker coach — analytical, Machiavellian, deeply psychological. Your player is asking you a question mid-hand. Answer it directly and conversationally, like a sharp coach sitting next to them at the table. No bullet points. Speak to them, not at them. Be concise but complete — 2-4 sentences max unless the question genuinely demands more.${profileSummary ? ' Factor in the player profile when relevant.' : ''}

${gameContext}

Player's question: "${question}"`
    : `You are a world-class poker coach with the strategic mind of Machiavelli — analytical, ruthless, and deeply psychological. Your player just wants your read on the situation. Respond like you're talking to them directly — sharp, confident, no fluff. Use 4-6 tight bullets.${profileSummary ? ' Reference the player profile to personalize your coaching — call out their tendencies and leaks where relevant.' : ''}

${gameContext}

Coaching focus:
- Think in ranges and equity, not just hand strength
- Factor in position: late position is power, early is constraint
- Address meta-game: table image, tendencies, exploitative vs. GTO
- If the player acted, critique or validate with specific reasoning
- Call out bluff spots, value sizing, trapping opportunities, fold equity
- Be decisive. Tell them what to do and exactly why.`;

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
      return res.status(502).json({ error: 'OpenAI error' });
    }

    const data = await openAiRes.json();
    const insights =
      data.output_text ??
      data.choices?.[0]?.message?.content?.[0]?.text ??
      data.choices?.[0]?.message?.content ??
      data.choices?.[0]?.text ??
      JSON.stringify(data);

    return res.status(200).json({ insights });
  } catch (e) {
    console.error('[insights] error:', e);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
