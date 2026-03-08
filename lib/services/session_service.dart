/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Service: session_service.dart
 * Purpose: Writes session, hand, and player action records to Supabase.
 *          Fails silently if Supabase is not configured.
 */

import '../supabase_client.dart';
import '../models/card.dart';
import '../models/game_settings.dart';
import '../models/player_action.dart';
import '../controllers/poker_game_controller.dart';

class SessionService {
  /// Creates a new session record. Returns the session ID, or null if Supabase is unavailable.
  static Future<String?> createSession(GameSettings settings) async {
    try {
      await SupabaseManager.ensureInitialized();
      if (!SupabaseManager.isInitialized) return null;

      final result = await SupabaseManager.client.from('sessions').insert({
        'players': settings.numberOfPlayers,
        'position': GameSettings.getPositionName(settings.userPosition),
        'small_blind': settings.smallBlind,
        'big_blind': settings.bigBlind,
      }).select('id').single();

      return result['id'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Creates a hand record under a session. Returns the hand ID, or null.
  static Future<String?> createHand({
    required String sessionId,
    required List<PokerCard> holeCards,
  }) async {
    try {
      if (!SupabaseManager.isInitialized) return null;

      final result = await SupabaseManager.client.from('hands').insert({
        'session_id': sessionId,
        'hole_cards': holeCards.map((c) => c.toString()).toList(),
        'community_cards': <String>[],
      }).select('id').single();

      return result['id'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Records the player's action at a given phase.
  static Future<void> recordAction({
    required String handId,
    required GamePhase phase,
    required PlayerAction action,
  }) async {
    try {
      if (!SupabaseManager.isInitialized) return;

      await SupabaseManager.client.from('player_actions').insert({
        'hand_id': handId,
        'phase': phase.name,
        'action': action.actionName,
        if (action.amount != null) 'amount': action.amount,
      });
    } catch (e) {
      return;
    }
  }

  /// Updates the hand record with final outcome data at showdown.
  static Future<void> completeHand({
    required String handId,
    required List<PokerCard> communityCards,
    required String finalHand,
    required double handStrength,
    required String phaseReached,
  }) async {
    try {
      if (!SupabaseManager.isInitialized) return;

      await SupabaseManager.client.from('hands').update({
        'community_cards': communityCards.map((c) => c.toString()).toList(),
        'final_hand': finalHand,
        'hand_strength': handStrength,
        'phase_reached': phaseReached,
      }).eq('id', handId);
    } catch (e) {
      return;
    }
  }
}
