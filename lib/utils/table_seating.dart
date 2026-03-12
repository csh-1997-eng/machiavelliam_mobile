/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Utility: table_seating.dart
 * Purpose: Generate opponent seat labels based on player count and hero position.
 *          Excludes hero's seat. Returns ordered list of seat strings (e.g. UTG, CO, BTN).
 */

import '../models/game_settings.dart';

class TableSeating {
  // Full 9-seat label sequence in positional order.
  static const _allSeats = ['UTG', 'UTG+1', 'MP', 'HJ', 'CO', 'BTN', 'SB', 'BB'];

  /// Returns seat labels for opponents (excludes hero seat).
  /// [players] total players including hero. [heroPosition] is the hero's Position enum.
  static List<String> seatLabels(int players, Position heroPosition) {
    final heroSeat = _heroSeatName(heroPosition, players);
    final seats = _seatsForCount(players);
    return seats.where((s) => s != heroSeat).toList();
  }

  static List<String> _seatsForCount(int players) {
    final count = players.clamp(2, 8);
    // Take the last `count` seats from the full list
    return _allSeats.sublist(_allSeats.length - count);
  }

  static String _heroSeatName(Position position, int players) {
    switch (position) {
      case Position.smallBlind:
        return 'SB';
      case Position.bigBlind:
        return 'BB';
      case Position.button:
        return 'BTN';
      case Position.late:
        return players >= 7 ? 'CO' : 'BTN';
      case Position.middle:
        return players >= 6 ? 'HJ' : 'MP';
      case Position.early:
        return 'UTG';
    }
  }
}
