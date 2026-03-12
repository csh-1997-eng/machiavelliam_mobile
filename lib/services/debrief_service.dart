/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Service: debrief_service.dart
 * Purpose: POST /api/debrief — fetches session retrospective coaching.
 *          Respects kMockInsights flag; returns mock immediately at zero cost.
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

const _kMockDebrief = '• Strong preflop discipline — you avoided speculative hands in early position\n'
    '• Aggression was inconsistent: you bet the flop well but checked back too often on turns\n'
    '• Folded to aggression 4 of 5 times when facing a raise on the flop — consider your pot odds\n'
    '• Bet sizing leak: your value bets averaged only 40% pot, leaving money on the table\n'
    '• One read stood out — you correctly identified the station at the table and targeted them\n'
    'Next session: commit to a bet size before you act, not after. Sizing is intent.';

class DebriefService {
  static Future<String?> getDebrief({required String sessionId}) async {
    if (kMockInsights) return _kMockDebrief;
    if (!kDebriefEnabled) return null;
    try {
      final res = await http.post(
        Uri.parse('$apiBaseUrl/api/debrief'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId}),
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map;
      return data['report'] as String?;
    } catch (e) {
      return null;
    }
  }
}
