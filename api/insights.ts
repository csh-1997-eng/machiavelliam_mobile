/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * API Route: /api/insights
 * Purpose: Generate Machiavellian poker coaching advice via OpenAI.
 *          Handles live hand mode, free-form Q&A, and scenario study mode.
 *          Prompt construction is fully typed — add new modes via PromptContext.
 */

import type { VercelRequest, VercelResponse } from '@vercel/node';

// ---------------------------------------------------------------------------
// Archetype library — mirrors lib/services/prompt_library.dart on the Dart side
// ---------------------------------------------------------------------------

const ARCHETYPE_DESCRIPTIONS: Record<string, string> = {
  nit: "Extremely tight. Plays only 10-15% of hands, raises 8-12%. Folds to aggression >70%. Almost never bluffs. Exploit by stealing their blinds relentlessly and folding to their strength.",
  tag: "Tight-aggressive. Plays 16-24%, raises 14-20%. Balanced, selective, respects position. Deny them positional edges — don't pay off their value bets.",
  lag: "Loose-aggressive. Plays 25-40%, raises 20-32%. High 3-bet frequency (12-16%). Bluffs a lot. Counter with a tighter calling range and trapping strong hands.",
  callingStation: "Loose-passive. Plays 35-55%, raises <10%. Calls down with weak holdings, rarely folds once invested. Never bluff them — bet relentlessly for value and size up on the river.",
  maniac: "Extremely aggressive. Plays 50%+, raises 35%+. Unpredictable sizing, bluffs at extreme frequency. Trap them — let them hang themselves.",
};

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface OpponentSummary {
  seat: string;
  archetype: string;
  stack?: number;
  lastAction?: string | null;
  isActive?: boolean;
}

interface RequestBody {
  // Scenario mode — free-form study input; all other fields optional when present
  scenario?: string | null;
  // Live hand mode
  phase?: string;
  settings?: {
    players: number;
    position: string;
    smallBlind: number;
    bigBlind: number;
  };
  userHoleCards?: string[];
  communityCards?: string[];
  evaluation?: string | null;
  handStrengthPercent?: number;
  playerAction?: { action: string; amount?: number } | null;
  question?: string | null;
  profileSummary?: string | null;
  // Phase 9+: coaching philosophy
  coachingMode?: 'balanced' | 'exploit';
  // Phase 10+: opponent simulation context
  opponents?: OpponentSummary[];
  pot?: number;
  heroStack?: number;
  spr?: number;
}

type InsightMode = 'scenario' | 'question' | 'live';

// ---------------------------------------------------------------------------
// Prompt helpers
// ---------------------------------------------------------------------------

function buildOpponentBlock(opponents?: OpponentSummary[]): string {
  if (!opponents?.length) return '';
  const active = opponents.filter(o => o.isActive !== false);
  const folded = opponents.filter(o => o.isActive === false);
  const lines: string[] = [];
  if (active.length) {
    lines.push('Active opponents:');
    for (const o of active) {
      const stack = o.stack != null ? ` ($${o.stack.toFixed(0)})` : '';
      const action = o.lastAction ? `, last action: ${o.lastAction.toUpperCase()}` : '';
      const desc = ARCHETYPE_DESCRIPTIONS[o.archetype] ?? o.archetype;
      lines.push(`  ${o.seat}${stack} — ${desc}${action}`);
    }
  }
  if (folded.length) {
    lines.push(`Folded: ${folded.map(o => `${o.seat} (${o.archetype})`).join(', ')}`);
  }
  return lines.join('\n');
}

function buildGameContext(body: RequestBody): string {
  const { phase, settings, userHoleCards, communityCards, evaluation, handStrengthPercent, playerAction, profileSummary, pot, heroStack, spr } = body;

  const actionContext = playerAction
    ? `Player's action this street: ${playerAction.action.toUpperCase()}${playerAction.amount ? ` $${playerAction.amount}` : ''}.`
    : 'Player has not yet acted this street.';

  const stackLine = (pot != null && heroStack != null)
    ? `\n- Pot: $${pot.toFixed(0)}  Hero stack: $${heroStack.toFixed(0)}${spr != null ? `  SPR: ${spr.toFixed(1)}` : ''}`
    : '';

  const opponentBlock = buildOpponentBlock(body.opponents);

  return `Current hand:
- Phase: ${phase}
- Players: ${settings?.players}, Hero position: ${settings?.position}
- Blinds: $${settings?.smallBlind}/$${settings?.bigBlind}
- Hole cards: ${userHoleCards?.join(', ') || 'N/A'}
- Community cards: ${communityCards?.join(', ') || 'None'}
- Hand: ${evaluation ?? 'N/A'} (${Math.round(handStrengthPercent ?? 0)}% raw strength)${stackLine}
- ${actionContext}${profileSummary ? `\n- ${profileSummary}` : ''}${opponentBlock ? `\n${opponentBlock}` : ''}`;
}

function buildCoachingFocus(coachingMode: 'balanced' | 'exploit', hasOpponents: boolean): string {
  if (coachingMode === 'exploit' && hasOpponents) {
    return `Coaching focus (EXPLOIT mode):
- Study the opponent profiles above — identify the most exploitable player in this spot
- Name the specific exploit: what are they doing wrong and how do you punish it?
- Deviate from GTO only where their leak justifies it — be precise about the deviation
- If multiple opponents remain, prioritize: who do you want in this pot and why?
- Pot odds and SPR: are the stack/pot dynamics favorable for your exploit line?
- Be decisive. Name the seat, name the weakness, name the play.`;
  }
  return `Coaching focus (GTO/BALANCED mode):
- Think in ranges and equity, not just hand strength
- Factor in position: late position is power, early is constraint
- Evaluate frequencies: are you bluffing and value-betting at the right ratio?
- Address pot odds and SPR: does the math support continuing?
- If the player acted, critique or validate with specific reasoning
- Be decisive. Tell them what to do and exactly why.`;
}

function buildScenarioPrompt(body: RequestBody): string {
  const { scenario, profileSummary } = body;
  return `You are a world-class poker coach with the strategic mind of Machiavelli — analytical, ruthless, deeply psychological. A player is presenting you with a hypothetical poker scenario for study. Break it down like a professional. Be decisive and specific — no platitudes. Use 4-8 tight bullets.${profileSummary ? ' Factor in the player profile when relevant.' : ''}

Scenario: ${scenario}

Analysis focus:
- Reconstruct the range dynamics for all parties
- Identify the dominant line and explain why it beats the alternatives
- What mistakes would a typical player make here, and why?
- How would you exploit each weakness in this spot?
- If there's a study lesson, name it directly`;
}

function buildQuestionPrompt(body: RequestBody): string {
  const { question, profileSummary } = body;
  const gameContext = buildGameContext(body);
  return `You are a world-class poker coach — analytical, Machiavellian, deeply psychological. Your player is asking you a question mid-hand. Answer it directly and conversationally, like a sharp coach sitting next to them at the table. No bullet points. Speak to them, not at them. Be concise but complete — 2-4 sentences max unless the question genuinely demands more.${profileSummary ? ' Factor in the player profile when relevant.' : ''}

${gameContext}

Player's question: "${question}"`;
}

function buildLivePrompt(body: RequestBody): string {
  const { profileSummary, coachingMode = 'balanced', opponents } = body;
  const gameContext = buildGameContext(body);
  const coachingFocus = buildCoachingFocus(coachingMode, !!opponents?.length);

  return `You are a world-class poker coach with the strategic mind of Machiavelli — analytical, ruthless, and deeply psychological. Your player wants your read on the situation. Respond like you're talking to them directly — sharp, confident, no fluff. Use 4-6 tight bullets.${profileSummary ? ' Reference the player profile to personalize your coaching — call out their tendencies and leaks where relevant.' : ''}

${gameContext}

${coachingFocus}`;
}

function getInsightMode(body: RequestBody): InsightMode {
  if (body.scenario) return 'scenario';
  if (body.question) return 'question';
  return 'live';
}

function getModelForInsightMode(mode: InsightMode): string {
  switch (mode) {
    case 'scenario':
      return 'gpt-4.1';
    case 'question':
    case 'live':
      return 'gpt-4.1-mini';
  }
}

// ---------------------------------------------------------------------------
// CORS
// ---------------------------------------------------------------------------

function setCors(res: VercelResponse) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}

// ---------------------------------------------------------------------------
// Handler
// ---------------------------------------------------------------------------

export default async function handler(req: VercelRequest, res: VercelResponse) {
  setCors(res);
  if (req.method === 'OPTIONS') return res.status(204).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const openAiKey = process.env.OPENAI_API_KEY;
  if (!openAiKey) return res.status(500).json({ error: 'OPENAI_API_KEY not configured' });

  const body = req.body as RequestBody;
  const mode = getInsightMode(body);

  let prompt: string;
  if (mode === 'scenario') {
    prompt = buildScenarioPrompt(body);
  } else if (mode === 'question') {
    prompt = buildQuestionPrompt(body);
  } else {
    prompt = buildLivePrompt(body);
  }

  try {
    const openAiRes = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${openAiKey}`,
      },
      body: JSON.stringify({
        model: getModelForInsightMode(mode),
        input: prompt,
        max_output_tokens: 400,
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
