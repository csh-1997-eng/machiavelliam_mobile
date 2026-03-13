/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Model: opponent_profile.dart
 * Purpose: Opponent archetype enum and mutable profile model used by OpponentAI
 *          and the coaching API for opponent context injection.
 */

import '../services/prompt_library.dart';

enum PlayerArchetype { nit, tag, lag, callingStation, maniac }

extension PlayerArchetypeX on PlayerArchetype {
  String get apiKey {
    switch (this) {
      case PlayerArchetype.nit:
        return 'nit';
      case PlayerArchetype.tag:
        return 'tag';
      case PlayerArchetype.lag:
        return 'lag';
      case PlayerArchetype.callingStation:
        return 'callingStation';
      case PlayerArchetype.maniac:
        return 'maniac';
    }
  }

  String get label => kArchetypeLabels[apiKey] ?? apiKey;

  Map<String, double> get freqs => kArchetypeFreqs[apiKey] ?? {};
}

class OpponentProfile {
  final String seatLabel;
  PlayerArchetype archetype;
  double stack;
  String? lastAction;
  double? lastActionAmount;
  bool isActive;

  OpponentProfile({
    required this.seatLabel,
    this.archetype = PlayerArchetype.tag,
    required this.stack,
    this.lastAction,
    this.lastActionAmount,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'seat': seatLabel,
        'archetype': archetype.apiKey,
        'stack': stack,
        if (lastAction != null) 'lastAction': lastAction,
        if (lastActionAmount != null) 'lastActionAmount': lastActionAmount,
        'isActive': isActive,
      };
}
