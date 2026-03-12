/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Service: opponent_ai.dart
 * Purpose: Rule-based opponent decision engine. Zero LLM cost.
 *          Uses archetype frequency tables from prompt_library.dart for
 *          weighted-random decisions. Returns updated pot after all opponents act.
 */

import 'dart:math';
import '../models/opponent_profile.dart';

class ActionResult {
  final String action; // 'fold', 'check', 'call', 'raise'
  final double? amount;

  const ActionResult(this.action, {this.amount});
}

class OpponentAI {
  static final _rng = Random();

  /// Decide what a single opponent does given the current street context.
  /// [currentBet] is the amount to call (0 = can check). [pot] is before this action.
  static ActionResult decideAction({
    required OpponentProfile opponent,
    required String phase,
    required double currentBet,
    required double pot,
    String heroAction = '',
  }) {
    if (!opponent.isActive) return const ActionResult('fold');

    final freqs = opponent.archetype.freqs;
    final vpip = freqs['vpip'] ?? 0.22;
    final pfr = freqs['pfr'] ?? 0.18;
    final foldToCbet = freqs['foldToCbet'] ?? 0.55;
    final threebet = freqs['threebet'] ?? 0.08;
    final aggFactor = freqs['aggFactor'] ?? 2.5;

    final roll = _rng.nextDouble();

    if (phase == 'preflop') {
      // No bet yet — opponent must decide to open or fold/limp
      if (currentBet == 0) {
        if (roll < pfr) return _raiseResult(opponent.archetype, pot, currentBet);
        if (roll < vpip) return const ActionResult('call');
        return const ActionResult('fold');
      }
      // Facing a raise — 3-bet, call, or fold
      if (heroAction == 'raise' || heroAction == 'bet') {
        if (roll < threebet) return _raiseResult(opponent.archetype, pot, currentBet);
        if (roll < vpip) return ActionResult('call', amount: currentBet);
        return const ActionResult('fold');
      }
    }

    // Postflop
    if (currentBet == 0) {
      // Can check or donk-bet
      final donkFreq = (aggFactor / 10.0).clamp(0.0, 0.30);
      if (roll < donkFreq) return _raiseResult(opponent.archetype, pot, 0);
      return const ActionResult('check');
    }

    // Facing a c-bet or postflop bet
    if (heroAction == 'bet' || heroAction == 'raise') {
      if (roll < foldToCbet) return const ActionResult('fold');
      final raiseFreq = (aggFactor / 15.0).clamp(0.0, 0.25);
      if (roll < foldToCbet + raiseFreq) {
        return _raiseResult(opponent.archetype, pot, currentBet);
      }
      return ActionResult('call', amount: currentBet);
    }

    // Default: check or fold
    if (currentBet == 0) return const ActionResult('check');
    if (roll < 0.5) return ActionResult('call', amount: currentBet);
    return const ActionResult('fold');
  }

  static ActionResult _raiseResult(PlayerArchetype archetype, double pot, double currentBet) {
    double raiseSize;
    switch (archetype) {
      case PlayerArchetype.nit:
        raiseSize = (currentBet > 0 ? currentBet * 2.5 : pot * 0.5).clamp(1, double.infinity);
        break;
      case PlayerArchetype.tag:
        raiseSize = (currentBet > 0 ? currentBet * 3.0 : pot * 0.65).clamp(1, double.infinity);
        break;
      case PlayerArchetype.lag:
        raiseSize = (currentBet > 0 ? currentBet * 3.5 : pot * 0.75).clamp(1, double.infinity);
        break;
      case PlayerArchetype.callingStation:
        raiseSize = (currentBet > 0 ? currentBet * 2.0 : pot * 0.4).clamp(1, double.infinity);
        break;
      case PlayerArchetype.maniac:
        raiseSize = (currentBet > 0 ? currentBet * 4.5 : pot * 1.0).clamp(1, double.infinity);
        break;
    }
    return ActionResult('raise', amount: raiseSize);
  }

  /// Resolve all active opponents left to act after the hero.
  /// Updates each opponent's [lastAction] and [stack] in place.
  /// Returns the updated pot total.
  static double resolveStreet({
    required List<OpponentProfile> opponents,
    required String phase,
    required double pot,
    required double currentBet,
    required String heroAction,
  }) {
    double updatedPot = pot;

    for (final opp in opponents) {
      if (!opp.isActive) continue;

      final result = decideAction(
        opponent: opp,
        phase: phase,
        currentBet: currentBet,
        pot: updatedPot,
        heroAction: heroAction,
      );

      opp.lastAction = result.action;

      switch (result.action) {
        case 'fold':
          opp.isActive = false;
          break;
        case 'call':
          final callAmt = (result.amount ?? currentBet).clamp(0, opp.stack);
          opp.stack -= callAmt;
          updatedPot += callAmt;
          break;
        case 'raise':
          final raiseAmt = (result.amount ?? currentBet * 2).clamp(0, opp.stack);
          opp.stack -= raiseAmt;
          updatedPot += raiseAmt;
          break;
        case 'check':
          break;
      }
    }

    return updatedPot;
  }
}
