/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Service: prompt_library.dart
 * Purpose: Canonical source for opponent archetype definitions and coaching mode
 *          descriptions used client-side for UI labels and API serialization.
 *          The authoritative prompt text lives in api/insights.ts (server-side).
 */

/// Opponent archetype labels for UI display.
const Map<String, String> kArchetypeLabels = {
  'nit': 'Nit',
  'tag': 'TAG',
  'lag': 'LAG',
  'callingStation': 'Station',
  'maniac': 'Maniac',
};

/// Human-readable archetype descriptions — injected into coaching prompts
/// to give the AI opponent context. Mirrors kArchetypeDescriptions in insights.ts.
const Map<String, String> kArchetypeDescriptions = {
  'nit':
      'Extremely tight. Plays only 10-15% of hands, raises 8-12%. Folds to aggression >70% of the time. Almost never bluffs. Can be exploited by stealing their blinds relentlessly and folding when they show strength.',
  'tag':
      'Tight-aggressive. Plays 16-24% of hands, raises 14-20%. Balanced, selective, respects position. Difficult to exploit directly — adjust by denying them positional edges and not paying off their value bets.',
  'lag':
      'Loose-aggressive. Plays 25-40%, raises 20-32%. High 3-bet frequency (12-16%). Uses position as a weapon and bluffs at high frequency. Counter with a tighter calling range and trapping strong hands.',
  'callingStation':
      'Loose-passive. Plays 35-55%, raises <10%. Calls down with weak holdings, rarely folds once invested. Never bluff them — bet relentlessly for value and size up on the river.',
  'maniac':
      'Extremely aggressive. Plays 50%+, raises 35%+. Unpredictable bet sizing, bluffs at extreme frequency. Counter by tightening your calling range and trapping — let them hang themselves.',
};

/// Frequency tables per archetype — used by OpponentAI for rule-based decisions.
/// Keys: vpip, pfr, foldToCbet, threebet (all as 0.0–1.0 probabilities).
const Map<String, Map<String, double>> kArchetypeFreqs = {
  'nit': {
    'vpip': 0.13,
    'pfr': 0.10,
    'foldToCbet': 0.72,
    'threebet': 0.04,
    'aggFactor': 1.2,
  },
  'tag': {
    'vpip': 0.22,
    'pfr': 0.18,
    'foldToCbet': 0.55,
    'threebet': 0.08,
    'aggFactor': 2.5,
  },
  'lag': {
    'vpip': 0.33,
    'pfr': 0.26,
    'foldToCbet': 0.38,
    'threebet': 0.14,
    'aggFactor': 3.5,
  },
  'callingStation': {
    'vpip': 0.48,
    'pfr': 0.07,
    'foldToCbet': 0.20,
    'threebet': 0.03,
    'aggFactor': 0.8,
  },
  'maniac': {
    'vpip': 0.58,
    'pfr': 0.40,
    'foldToCbet': 0.22,
    'threebet': 0.24,
    'aggFactor': 5.0,
  },
};

/// Coaching mode intent strings — used for API serialization and UI labels.
const Map<String, String> kCoachingModeLabels = {
  'balanced': 'GTO',
  'exploit': 'Exploit',
};

/// Ordered list of archetype keys for UI iteration (picker lists, etc.).
const List<String> kArchetypeOrder = [
  'nit',
  'tag',
  'lag',
  'callingStation',
  'maniac',
];
