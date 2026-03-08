/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Controller: poker_game_controller.dart
 * Purpose: Game state machine — manages phases, card dealing, action tracking,
 *          and Supabase session/hand persistence.
 */

import '../models/card.dart';
import '../models/deck.dart';
import '../models/game_settings.dart';
import '../models/poker_hand.dart';
import '../models/player_action.dart';
import '../services/session_service.dart';

enum GamePhase { preflop, flop, turn, river, showdown }

class PokerGameController {
  late Deck _deck;
  late GameSettings _settings;
  List<PokerCard> _communityCards = [];
  List<PokerCard> _userHoleCards = [];
  GamePhase _currentPhase = GamePhase.preflop;
  bool _gameStarted = false;
  bool _handComplete = false;
  PokerHand? _finalHand;

  // Session/hand tracking
  String? _sessionId;
  String? _currentHandId;
  final Map<GamePhase, PlayerAction> _phaseActions = {};

  // Getters
  GameSettings get settings => _settings;
  List<PokerCard> get communityCards => List.unmodifiable(_communityCards);
  List<PokerCard> get userHoleCards => List.unmodifiable(_userHoleCards);
  GamePhase get currentPhase => _currentPhase;
  bool get gameStarted => _gameStarted;
  bool get handComplete => _handComplete;
  PokerHand? get finalHand => _finalHand;
  PlayerAction? get currentPhaseAction => _phaseActions[_currentPhase];
  Map<GamePhase, PlayerAction> get allPhaseActions => Map.unmodifiable(_phaseActions);

  void initializeGame(GameSettings settings) {
    _settings = settings;
    _deck = Deck.createMultipleDecks(settings.numberOfDecks);
    _communityCards = [];
    _userHoleCards = [];
    _currentPhase = GamePhase.preflop;
    _gameStarted = false;
    _handComplete = false;
    _finalHand = null;
    _phaseActions.clear();
    _currentHandId = null;
    // Fire and forget — session ID will be ready before any hand is dealt
    _initSession();
  }

  Future<void> _initSession() async {
    _sessionId = await SessionService.createSession(_settings);
  }

  Future<void> startNewHand() async {
    if (!_gameStarted) _gameStarted = true;

    _deck.reset();
    _communityCards = [];
    _userHoleCards = [];
    _currentPhase = GamePhase.preflop;
    _handComplete = false;
    _finalHand = null;
    _phaseActions.clear();
    _currentHandId = null;

    _userHoleCards = _deck.dealCards(2);

    if (_sessionId != null) {
      _currentHandId = await SessionService.createHand(
        sessionId: _sessionId!,
        holeCards: _userHoleCards,
      );
    }
  }

  /// Records what the player decided to do at the current phase.
  void recordAction(ActionType action, {double? amount}) {
    final playerAction = PlayerAction(action: action, amount: amount);
    _phaseActions[_currentPhase] = playerAction;

    if (_currentHandId != null) {
      SessionService.recordAction(
        handId: _currentHandId!,
        phase: _currentPhase,
        action: playerAction,
      );
    }
  }

  void dealFlop() {
    if (_currentPhase != GamePhase.preflop) {
      throw StateError('Cannot deal flop in current phase: $_currentPhase');
    }
    _communityCards = _deck.dealCards(3);
    _currentPhase = GamePhase.flop;
  }

  void dealTurn() {
    if (_currentPhase != GamePhase.flop) {
      throw StateError('Cannot deal turn in current phase: $_currentPhase');
    }
    _communityCards.addAll(_deck.dealCards(1));
    _currentPhase = GamePhase.turn;
  }

  void dealRiver() {
    if (_currentPhase != GamePhase.turn) {
      throw StateError('Cannot deal river in current phase: $_currentPhase');
    }
    _communityCards.addAll(_deck.dealCards(1));
    _currentPhase = GamePhase.river;
  }

  void completeHand() {
    if (_currentPhase != GamePhase.river) {
      throw StateError('Cannot complete hand in current phase: $_currentPhase');
    }
    _currentPhase = GamePhase.showdown;
    _handComplete = true;
    _finalHand = PokerHand.evaluateHand(_userHoleCards, _communityCards);

    if (_currentHandId != null && _finalHand != null) {
      SessionService.completeHand(
        handId: _currentHandId!,
        communityCards: _communityCards,
        finalHand: _finalHand!.handName,
        handStrength: getHandStrength(),
        phaseReached: _currentPhase.name,
      );
    }
  }

  PokerHand? getCurrentHandEvaluation() {
    if (_userHoleCards.length == 2 && _communityCards.length >= 3) {
      List<PokerCard> availableCommunityCards = _communityCards;
      if (_communityCards.length < 5) {
        availableCommunityCards = List.from(_communityCards);
        while (availableCommunityCards.length < 5) {
          availableCommunityCards.add(PokerCard(Suit.hearts, Rank.two));
        }
      }
      return PokerHand.evaluateHand(_userHoleCards, availableCommunityCards);
    }
    return null;
  }

  double getHandStrength() {
    if (_userHoleCards.length != 2) return 0.0;
    PokerHand? evaluation = getCurrentHandEvaluation();
    if (evaluation == null) return 0.0;
    double strength = evaluation.rank.index / HandRank.values.length;
    if (evaluation.kickers.isNotEmpty) {
      strength += evaluation.kickers.first / 14.0 * 0.1;
    }
    return (strength * 100).clamp(0.0, 100.0);
  }

  String getPositionAdvice() {
    String baseAdvice = GameSettings.getPositionDescription(_settings.userPosition);
    if (_userHoleCards.length == 2) {
      double handStrength = getHandStrength();
      if (handStrength > 80) {
        return "$baseAdvice\n\nStrong hand! Consider betting or raising.";
      } else if (handStrength > 60) {
        return "$baseAdvice\n\nGood hand. Play according to position.";
      } else if (handStrength > 40) {
        return "$baseAdvice\n\nMarginal hand. Be cautious in early position.";
      } else {
        return "$baseAdvice\n\nWeak hand. Consider folding unless in late position.";
      }
    }
    return baseAdvice;
  }

  void resetGame() {
    _gameStarted = false;
    _handComplete = false;
    _communityCards = [];
    _userHoleCards = [];
    _currentPhase = GamePhase.preflop;
    _finalHand = null;
    _phaseActions.clear();
    _currentHandId = null;
  }

  String getPhaseDescription() {
    switch (_currentPhase) {
      case GamePhase.preflop:
        return 'Pre-flop: You have your hole cards. Make your decision.';
      case GamePhase.flop:
        return 'Flop: 3 community cards revealed. Evaluate your hand.';
      case GamePhase.turn:
        return 'Turn: 4th community card revealed.';
      case GamePhase.river:
        return 'River: Final community card revealed.';
      case GamePhase.showdown:
        return 'Showdown: Hand complete. Final hand evaluated.';
    }
  }

  bool canProceedToNextPhase() {
    switch (_currentPhase) {
      case GamePhase.preflop:
        return _userHoleCards.length == 2;
      case GamePhase.flop:
        return _communityCards.length >= 3;
      case GamePhase.turn:
        return _communityCards.length >= 4;
      case GamePhase.river:
        return _communityCards.length >= 5;
      case GamePhase.showdown:
        return _handComplete;
    }
  }

  GamePhase? getNextPhase() {
    switch (_currentPhase) {
      case GamePhase.preflop:
        return GamePhase.flop;
      case GamePhase.flop:
        return GamePhase.turn;
      case GamePhase.turn:
        return GamePhase.river;
      case GamePhase.river:
        return GamePhase.showdown;
      case GamePhase.showdown:
        return null;
    }
  }

  bool advanceToNextPhase() {
    GamePhase? nextPhase = getNextPhase();
    if (nextPhase == null) return false;
    switch (nextPhase) {
      case GamePhase.flop:
        dealFlop();
        break;
      case GamePhase.turn:
        dealTurn();
        break;
      case GamePhase.river:
        dealRiver();
        break;
      case GamePhase.showdown:
        completeHand();
        break;
      default:
        return false;
    }
    return true;
  }
}
