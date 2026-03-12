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

// Mock responses used when kMockInsights = true (zero API cost).
const _kMockLive = '• Strong preflop hand — you\'re ahead of most calling ranges\n'
    '• Position advantage: use it to control pot size\n'
    '• C-bet the flop at ~60% pot — take it down or get information\n'
    '• If called, slow down on non-improving turns unless you pick up equity\n'
    '• Watch for check-raises — they\'re telling you something';

const _kMockQuestion = 'Given your position and hand strength, the call is mathematically sound here. '
    'The pot odds justify seeing another card. '
    'Be prepared to fold the turn if the board shifts against you.';

const _kMockScenario = '• AJo on BTN facing MP raise + CO call: classic squeeze or fold spot\n'
    '• Squeezing builds the pot with initiative; flatting traps you in bad position multi-way\n'
    '• Against a tight MP raiser, AJo is dominated often enough to make folding defensible\n'
    '• If stacks are 100BB+, prefer a squeeze to 3x the open; use your stack as leverage\n'
    '• Study lesson: position is power, but initiative is force — combine them when you can';

class InsightsService {
  static String? lastResponseId;
  static Future<String?> getScenarioInsights({
    required String scenario,
    String? profileSummary,
  }) async {
    if (kMockInsights) return _kMockScenario;
    if (!kScenarioEnabled) return null;
    try {
      final res = await http.post(
        Uri.parse('$apiBaseUrl/api/insights'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'scenario': scenario,
          if (profileSummary != null && profileSummary.isNotEmpty) 'profileSummary': profileSummary,
        }),
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map;
      return data['insights'] as String?;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getInsights({
    required List<PokerCard> userHoleCards,
    required List<PokerCard> communityCards,
    required PokerHand? currentEvaluation,
    required double handStrengthPercent,
    required GameSettings settings,
    required String phase,
    PlayerAction? playerAction,
    String? question,
    String? profileSummary,
    String coachingMode = 'balanced',
    List<Map<String, dynamic>>? opponents,
    double? pot,
    double? heroStack,
    double? spr,
    String? previousResponseId,
  }) async {
    if (kMockInsights) {
      return (question != null && question.isNotEmpty) ? _kMockQuestion : _kMockLive;
    }
    if (!kCoachingEnabled) return null;
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
          'coachingMode': coachingMode,
          if (playerAction != null) 'playerAction': playerAction.toJson(),
          if (question != null && question.isNotEmpty) 'question': question,
          if (profileSummary != null && profileSummary.isNotEmpty) 'profileSummary': profileSummary,
          if (opponents != null && opponents.isNotEmpty) 'opponents': opponents,
          if (pot != null) 'pot': pot,
          if (heroStack != null) 'heroStack': heroStack,
          if (spr != null) 'spr': spr,
          if (previousResponseId != null) 'previousResponseId': previousResponseId,
        }),
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map;
      lastResponseId = data['responseId'] as String?;
      return data['insights'] as String?;
    } catch (e) {
      return null;
    }
  }
}
