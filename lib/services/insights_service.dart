/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Service: insights_service.dart
 * Purpose: Fetches AI coaching advice from Vercel /api/insights → OpenAI.
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card.dart';
import '../models/poker_hand.dart';
import '../models/game_settings.dart';
import '../models/player_action.dart';
import 'api_client.dart';

class InsightsService {
  static Future<String?> getInsights({
    required List<PokerCard> userHoleCards,
    required List<PokerCard> communityCards,
    required PokerHand? currentEvaluation,
    required double handStrengthPercent,
    required GameSettings settings,
    required String phase,
    PlayerAction? playerAction,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$apiBaseUrl/api/insights'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phase': phase,
          'settings': {
            'players': settings.numberOfPlayers,
            'position': GameSettings.getPositionName(settings.userPosition),
            'smallBlind': settings.smallBlind,
            'bigBlind': settings.bigBlind,
          },
          'userHoleCards': userHoleCards.map((c) => c.toString()).toList(),
          'communityCards': communityCards.map((c) => c.toString()).toList(),
          'evaluation': currentEvaluation?.handName,
          'handStrengthPercent': handStrengthPercent,
          if (playerAction != null) 'playerAction': playerAction.toJson(),
        }),
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map;
      return data['insights'] as String?;
    } catch (e) {
      return null;
    }
  }
}
