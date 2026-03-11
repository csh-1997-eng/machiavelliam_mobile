/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Service: profile_service.dart
 * Purpose: Fetches aggregated player stats from Vercel /api/profile → Neon.
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class PlayerProfile {
  final int totalHands;
  final int vpip;
  final int pfr;
  final double aggressionFactor;
  final String style;
  final List<String> leaks;
  final List<Map<String, dynamic>> byPosition;
  final String? summary;

  const PlayerProfile({
    required this.totalHands,
    required this.vpip,
    required this.pfr,
    required this.aggressionFactor,
    required this.style,
    required this.leaks,
    required this.byPosition,
    this.summary,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
        totalHands: (json['totalHands'] as num).toInt(),
        vpip: (json['vpip'] as num).toInt(),
        pfr: (json['pfr'] as num).toInt(),
        aggressionFactor: (json['aggressionFactor'] as num).toDouble(),
        style: json['style'] as String,
        leaks: List<String>.from(json['leaks'] as List),
        byPosition: List<Map<String, dynamic>>.from(json['byPosition'] as List),
        summary: json['summary'] as String?,
      );
}

class ProfileService {
  static Future<PlayerProfile?> getProfile() async {
    if (!kProfileEnabled) return null;
    try {
      final res = await http.get(
        Uri.parse('$apiBaseUrl/api/profile'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode != 200) return null;
      return PlayerProfile.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}
