import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_client.dart';
import '../models/card.dart';
import '../models/poker_hand.dart';
import '../models/game_settings.dart';

class InsightsService {
  static const String _edgeFunctionName = 'poker-insights';

  static Future<String?> getInsights({
    required List<PokerCard> userHoleCards,
    required List<PokerCard> communityCards,
    required PokerHand? currentEvaluation,
    required double handStrengthPercent,
    required GameSettings settings,
    required String phase,
  }) async {
    await SupabaseManager.ensureInitialized();

    final SupabaseClient client = SupabaseManager.client;
    if (client.rest.url.isEmpty) {
      return null;
    }

    final payload = {
      'phase': phase,
      'settings': {
        'players': settings.numberOfPlayers,
        'position': GameSettings.getPositionName(settings.userPosition),
        'smallBlind': settings.smallBlind,
        'bigBlind': settings.bigBlind,
        'decks': settings.numberOfDecks,
      },
      'userHoleCards': userHoleCards.map((c) => c.toString()).toList(),
      'communityCards': communityCards.map((c) => c.toString()).toList(),
      'evaluation': currentEvaluation?.handName,
      'handStrengthPercent': handStrengthPercent,
    };

    final response = await client.functions.invoke(
      _edgeFunctionName,
      body: jsonEncode(payload),
    );

    if (response.data == null) return null;
    if (response.data is String) return response.data as String;
    if (response.data is Map && (response.data as Map).containsKey('insights')) {
      return (response.data as Map)['insights'] as String?;
    }
    return response.data.toString();
  }
}


