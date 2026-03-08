/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Model: player_action.dart
 * Purpose: Represents a player's betting decision at a given phase
 */

enum ActionType { fold, check, call, bet, raise }

class PlayerAction {
  final ActionType action;
  final double? amount;
  final DateTime timestamp;

  PlayerAction({
    required this.action,
    this.amount,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get actionName => action.name;

  Map<String, dynamic> toJson() => {
        'action': actionName,
        if (amount != null) 'amount': amount,
        'timestamp': timestamp.toIso8601String(),
      };
}
