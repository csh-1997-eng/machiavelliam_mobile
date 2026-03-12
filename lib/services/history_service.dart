/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Service: history_service.dart
 * Purpose: GET /api/history — paginated hand history records for a session.
 *          Respects kHistoryEnabled flag.
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class HandAction {
  final String phase;
  final String action;
  final double? amount;

  const HandAction({required this.phase, required this.action, this.amount});

  factory HandAction.fromJson(Map<String, dynamic> j) => HandAction(
        phase: j['phase'] as String,
        action: j['action'] as String,
        amount: (j['amount'] as num?)?.toDouble(),
      );
}

class HandHistoryRecord {
  final String id;
  final List<String> holeCards;
  final List<String> communityCards;
  final String? finalHand;
  final double? handStrength;
  final String? phaseReached;
  final String createdAt;
  final List<HandAction> actions;

  const HandHistoryRecord({
    required this.id,
    required this.holeCards,
    required this.communityCards,
    this.finalHand,
    this.handStrength,
    this.phaseReached,
    required this.createdAt,
    required this.actions,
  });

  factory HandHistoryRecord.fromJson(Map<String, dynamic> j) => HandHistoryRecord(
        id: j['id'] as String,
        holeCards: List<String>.from(j['holeCards'] as List),
        communityCards: List<String>.from(j['communityCards'] as List? ?? []),
        finalHand: j['finalHand'] as String?,
        handStrength: (j['handStrength'] as num?)?.toDouble(),
        phaseReached: j['phaseReached'] as String?,
        createdAt: j['createdAt'] as String,
        actions: (j['actions'] as List? ?? [])
            .map((a) => HandAction.fromJson(a as Map<String, dynamic>))
            .toList(),
      );

  /// Synthesize a scenario description for the ScenarioScreen pre-populate.
  String toScenarioString() {
    final cards = holeCards.join(', ');
    final board = communityCards.isNotEmpty ? communityCards.join(', ') : 'no board';
    final result = finalHand ?? 'unknown result';
    final actionStr = actions.map((a) => '${a.phase.toUpperCase()}: ${a.action.toUpperCase()}'
        '${a.amount != null ? ' \$${a.amount!.toStringAsFixed(0)}' : ''}').join(' → ');
    return 'Hole cards: $cards | Board: $board | Result: $result | Actions: $actionStr\n\nWhat did I do well here? Where did I leave money on the table?';
  }
}

class HistoryService {
  static Future<({List<HandHistoryRecord> hands, bool hasMore})> getHistory({
    String? sessionId,
    int page = 0,
  }) async {
    if (!kHistoryEnabled) return (hands: <HandHistoryRecord>[], hasMore: false);
    try {
      final uri = Uri.parse('$apiBaseUrl/api/history').replace(
        queryParameters: {
          if (sessionId != null) 'sessionId': sessionId,
          'page': page.toString(),
        },
      );
      final res = await http.get(uri);
      if (res.statusCode != 200) return (hands: <HandHistoryRecord>[], hasMore: false);
      final data = jsonDecode(res.body) as Map;
      final hands = (data['hands'] as List)
          .map((h) => HandHistoryRecord.fromJson(h as Map<String, dynamic>))
          .toList();
      return (hands: hands, hasMore: data['hasMore'] == true);
    } catch (e) {
      return (hands: <HandHistoryRecord>[], hasMore: false);
    }
  }
}
