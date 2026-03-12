/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Widget: glossary_tip.dart
 * Purpose: Inline (i) icon that opens a compact bottom sheet with
 *          a one-line poker term definition. Teaches while you play.
 */

import 'package:flutter/material.dart';
import '../theme/palazzo_colors.dart';

const Map<String, String> kGlossary = {
  // Positions
  'UTG': 'Under the Gun \u2014 first to act preflop. Tightest position at the table.',
  'UTG+1': 'One seat after UTG. Still early position \u2014 play tight.',
  'MP': 'Middle Position \u2014 slightly wider range than early position.',
  'CO': 'Cutoff \u2014 one seat before the Button. Strong stealing position.',
  'BTN': 'Button \u2014 last to act postflop. The most powerful seat at the table.',
  'SB': 'Small Blind \u2014 forced half-bet, first to act postflop. Worst position.',
  'BB': 'Big Blind \u2014 forced full bet. Defends wide but plays out of position.',

  // Streets
  'Preflop': 'Before community cards. Action starts left of BB.',
  'Flop': 'First three community cards dealt face-up.',
  'Turn': 'Fourth community card. Bets double on most streets.',
  'River': 'Fifth and final community card. Last chance to bet.',
  'Showdown': 'Cards revealed. Best five-card hand wins the pot.',

  // Stats
  'VPIP': 'Voluntarily Put In Pot \u2014 % of hands you play. Higher = looser.',
  'PFR': 'Pre-Flop Raise \u2014 % of hands you raise preflop. Higher = more aggressive.',
  'AF': 'Aggression Factor \u2014 (bets + raises) / calls. Above 1 = aggressive.',
  'SPR': 'Stack-to-Pot Ratio \u2014 your effective stack / pot size. Low SPR = committed.',

  // Actions & concepts
  'C-bet': 'Continuation Bet \u2014 betting the flop after raising preflop. Takes initiative.',
  '3-bet': 'Re-raising a raise. The third bet in a preflop sequence.',
  '4-bet': 'Re-raising a 3-bet. Usually signals a premium hand or a bluff.',
  'Pot Odds': 'Ratio of pot size to your call cost. Guides call vs fold math.',
  'Equity': 'Your share of the pot based on probability of winning.',
  'Fold Equity': 'The value gained from opponents folding to your bet.',
  'Range': 'The set of all hands a player could have given their actions.',
  'Position': 'Where you sit relative to the dealer. Later = more information = more power.',
  'Blocker': 'A card you hold that reduces the chance your opponent has a specific hand.',

  // Hand types
  'Suited': 'Two cards of the same suit. ~3% more equity than offsuit.',
  'Offsuit': 'Two cards of different suits. Abbreviated with "o" (e.g., AKo).',
  'Pocket Pair': 'Two cards of the same rank (e.g., 77). About 1 in 17 deals.',
  'Connectors': 'Two sequential cards (e.g., 89). Good for straights.',

  // Archetypes
  'Nit': 'Ultra-tight player. Plays ~13% of hands. Folds to aggression.',
  'TAG': 'Tight-Aggressive. Solid, position-aware, balanced. The default threat.',
  'LAG': 'Loose-Aggressive. Wide range, lots of pressure. Uses position well.',
  'Calling Station': 'Calls everything, rarely raises, never folds. Stop bluffing them.',
  'Maniac': 'Hyper-aggressive. Bets 50%+ of hands with random sizings.',

  // Coaching modes
  'GTO': 'Game Theory Optimal \u2014 unexploitable strategy based on frequencies and balance.',
  'Exploit': 'Deviating from GTO to target specific opponent leaks.',
};

class GlossaryTip extends StatelessWidget {
  final String term;
  final double size;
  final Color? color;

  const GlossaryTip({
    super.key,
    required this.term,
    this.size = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final definition = kGlossary[term];
    if (definition == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showDefinition(context, term, definition),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(
          Icons.info_outline,
          size: size,
          color: color ?? kTextSecondary.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  static void _showDefinition(BuildContext context, String term, String definition) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: kBorder),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 3,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              term,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kGold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              definition,
              style: const TextStyle(
                fontSize: 14,
                color: kTextPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Inline label with glossary tip attached
class GlossaryLabel extends StatelessWidget {
  final String text;
  final String? glossaryTerm;
  final TextStyle? style;

  const GlossaryLabel({
    super.key,
    required this.text,
    this.glossaryTerm,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final term = glossaryTerm ?? text;
    final hasTip = kGlossary.containsKey(term);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: style),
        if (hasTip) ...[
          const SizedBox(width: 2),
          GlossaryTip(term: term, size: 12),
        ],
      ],
    );
  }
}
