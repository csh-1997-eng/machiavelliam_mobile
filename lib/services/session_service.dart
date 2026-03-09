/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Service: session_service.dart
 * Purpose: Persists sessions, hands, and player actions via Vercel API routes → Neon.
 *          All calls fail silently — never block the game.
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card.dart';
import '../models/game_settings.dart';
import '../models/player_action.dart';
import '../controllers/poker_game_controller.dart';
import 'api_client.dart';

class SessionService {
  static Future<String?> createSession(GameSettings settings) async {
    if (!kSessionPersistenceEnabled) return null;
    try {
      final res = await http.post(
        Uri.parse('$apiBaseUrl/api/sessions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'players': settings.numberOfPlayers,
          'position': GameSettings.getPositionName(settings.userPosition),
          'smallBlind': settings.smallBlind,
          'bigBlind': settings.bigBlind,
          'buyIn': settings.buyIn,
        }),
      );
      if (res.statusCode != 201) return null;
      return (jsonDecode(res.body) as Map)['id'] as String?;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> createHand({
    required String sessionId,
    required List<PokerCard> holeCards,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$apiBaseUrl/api/hands'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'holeCards': holeCards.map((c) => c.toString()).toList(),
        }),
      );
      if (res.statusCode != 201) return null;
      return (jsonDecode(res.body) as Map)['id'] as String?;
    } catch (e) {
      return null;
    }
  }

  static Future<void> recordAction({
    required String handId,
    required GamePhase phase,
    required PlayerAction action,
  }) async {
    try {
      await http.post(
        Uri.parse('$apiBaseUrl/api/actions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'handId': handId,
          'phase': phase.name,
          'action': action.actionName,
          if (action.amount != null) 'amount': action.amount,
        }),
      );
    } catch (_) {}
  }

  static Future<void> completeHand({
    required String handId,
    required List<PokerCard> communityCards,
    required String finalHand,
    required double handStrength,
    required String phaseReached,
  }) async {
    try {
      await http.patch(
        Uri.parse('$apiBaseUrl/api/hands'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'handId': handId,
          'communityCards': communityCards.map((c) => c.toString()).toList(),
          'finalHand': finalHand,
          'handStrength': handStrength,
          'phaseReached': phaseReached,
        }),
      );
    } catch (_) {}
  }
}
