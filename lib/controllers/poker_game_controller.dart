/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Controller: poker_game_controller.dart
 * Purpose: Game state machine — manages phases, card dealing, action tracking,
 *          and Neon session/hand persistence via Vercel API routes.
 */

import '../models/card.dart';
import '../models/deck.dart';
import '../models/game_settings.dart';
import '../models/poker_hand.dart';
import '../models/player_action.dart';
import '../models/opponent_profile.dart';
import '../services/session_service.dart';
import '../services/opponent_ai.dart';

enum GamePhase { preflop, flop, turn, river, showdown }

class LegalActions {
  final Set<ActionType> actions;
  final double minBet;
  final double maxBet;
  final double callAmount;

  const LegalActions({
    required this.actions,
    required this.minBet,
    required this.maxBet,
    required this.callAmount,
  });

  bool get canFold => actions.contains(ActionType.fold);
  bool get canCheck => actions.contains(ActionType.check);
  bool get canCall => actions.contains(ActionType.call);
  bool get canBet => actions.contains(ActionType.bet);
  bool get canRaise => actions.contains(ActionType.raise);
}

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
  Future<void>? _sessionFuture;
  final Map<GamePhase, PlayerAction> _phaseActions = {};

  // Phase 10: opponent simulation + pot/stack tracking
  List<OpponentProfile> _opponents = [];
  double _pot = 0.0;
  double _heroStack = 0.0;
  double _currentStreetBet = 0.0;

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
  String? get sessionId => _sessionId;
  List<OpponentProfile> get opponents => List.unmodifiable(_opponents);
  double get pot => _pot;
  double get heroStack => _heroStack;
  double get spr => (_pot > 0) ? (_heroStack / _pot) : 0.0;
  double get currentStreetBet => _currentStreetBet;
  String? get showdownResult => _showdownResult;

  // Showdown
  String? _showdownResult;

  /// Returns the set of legal actions the hero can take right now,
  /// along with min/max bet sizing where applicable.
  LegalActions getLegalActions() {
    if (_handComplete || !_gameStarted) {
      return LegalActions(actions: {}, minBet: 0, maxBet: 0, callAmount: 0);
    }

    final bb = _settings.bigBlind.toDouble();
    final facingBet = _currentStreetBet > 0;
    final actions = <ActionType>{};

    // Fold is always legal when facing a bet
    if (facingBet) actions.add(ActionType.fold);

    // Check only when no bet to face
    if (!facingBet) actions.add(ActionType.check);

    // Call when facing a bet and hero has chips
    if (facingBet && _heroStack > 0) actions.add(ActionType.call);

    // Bet when no outstanding bet, raise when facing a bet
    if (_heroStack > 0) {
      if (facingBet) {
        actions.add(ActionType.raise);
      } else {
        actions.add(ActionType.bet);
      }
    }

    final callAmount = facingBet ? _currentStreetBet.clamp(0.0, _heroStack) : 0.0;
    final minBet = facingBet ? (_currentStreetBet * 2).clamp(bb, _heroStack) : bb.clamp(0.0, _heroStack);
    final maxBet = _heroStack;

    return LegalActions(
      actions: actions,
      minBet: minBet,
      maxBet: maxBet,
      callAmount: callAmount,
    );
  }

  /// Context string for the turn indicator banner.
  String getTurnContext() {
    if (!_gameStarted || _handComplete) return '';
    final legal = getLegalActions();
    if (_currentStreetBet > 0) {
      return 'Facing \$${_currentStreetBet.toStringAsFixed(0)} bet';
    }
    if (legal.actions.contains(ActionType.check)) {
      return 'No bet to you — check or bet';
    }
    return '';
  }

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
    _heroStack = settings.buyIn;
    _pot = 0.0;
    _currentStreetBet = 0.0;
    _showdownResult = null;
    _sessionFuture = _initSession();
  }

  void setOpponents(List<OpponentProfile> opponents) {
    _opponents = opponents;
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
    _currentStreetBet = 0.0;

    _showdownResult = null;

    // Post blinds — hero posts BB, deducted from stack
    final bb = _settings.bigBlind.toDouble();
    final sb = _settings.smallBlind.toDouble();
    _heroStack -= bb;
    _pot = bb + sb;
    _currentStreetBet = bb;

    // Re-activate all opponents with fresh stacks if they folded last hand
    for (final opp in _opponents) {
      opp.isActive = true;
      opp.lastAction = null;
    }

    _userHoleCards = _deck.dealCards(2);

    await _sessionFuture; // ensure session is ready before creating hand
    if (_sessionId != null) {
      _currentHandId = await SessionService.createHand(
        sessionId: _sessionId!,
        holeCards: _userHoleCards,
      );
    }
  }

  /// Records what the player decided to do at the current phase.
  /// Updates pot/stack and resolves opponent actions via OpponentAI.
  void recordAction(ActionType action, {double? amount}) {
    final legal = getLegalActions();
    if (!legal.actions.contains(action)) return; // illegal action — ignore

    // Clamp bet/raise to valid range
    double? validAmount = amount;
    if (action == ActionType.bet || action == ActionType.raise) {
      validAmount = (amount ?? legal.minBet).clamp(legal.minBet, legal.maxBet);
    }

    final playerAction = PlayerAction(action: action, amount: validAmount);
    _phaseActions[_currentPhase] = playerAction;

    switch (action) {
      case ActionType.bet:
      case ActionType.raise:
        _heroStack -= validAmount!;
        _pot += validAmount;
        _currentStreetBet = validAmount;
        break;
      case ActionType.call:
        final callAmt = legal.callAmount;
        _heroStack -= callAmt;
        _pot += callAmt;
        break;
      case ActionType.check:
      case ActionType.fold:
        break;
    }

    // Resolve opponent responses (rule-based, zero LLM cost)
    if (_opponents.isNotEmpty) {
      _pot = OpponentAI.resolveStreet(
        opponents: _opponents,
        phase: _currentPhase.name,
        pot: _pot,
        currentBet: _currentStreetBet,
        heroAction: action.name,
      );
    }

    if (_currentHandId != null) {
      SessionService.recordAction(
        handId: _currentHandId!,
        phase: _currentPhase,
        action: playerAction,
      );
    }
  }

  /// Reset street bet when advancing phase.
  void _resetStreetBet() {
    _currentStreetBet = 0.0;
    for (final opp in _opponents) {
      if (opp.isActive) {
        opp.lastAction = null;
        opp.lastActionAmount = null;
      }
    }
  }

  void dealFlop() {
    if (_currentPhase != GamePhase.preflop) {
      throw StateError('Cannot deal flop in current phase: $_currentPhase');
    }
    _communityCards = _deck.dealCards(3);
    _currentPhase = GamePhase.flop;
    _resetStreetBet();
  }

  void dealTurn() {
    if (_currentPhase != GamePhase.flop) {
      throw StateError('Cannot deal turn in current phase: $_currentPhase');
    }
    _communityCards.addAll(_deck.dealCards(1));
    _currentPhase = GamePhase.turn;
    _resetStreetBet();
  }

  void dealRiver() {
    if (_currentPhase != GamePhase.turn) {
      throw StateError('Cannot deal river in current phase: $_currentPhase');
    }
    _communityCards.addAll(_deck.dealCards(1));
    _currentPhase = GamePhase.river;
    _resetStreetBet();
  }

  void completeHand() {
    if (_currentPhase != GamePhase.river) {
      throw StateError('Cannot complete hand in current phase: $_currentPhase');
    }
    final lastBettingPhase = _currentPhase.name;
    _currentPhase = GamePhase.showdown;
    _handComplete = true;
    _finalHand = PokerHand.evaluateHand(_userHoleCards, _communityCards);

    // Check if hero folded — opponents win
    final heroFolded = _phaseActions.values.any((a) => a.action == ActionType.fold);
    final activeOpponents = _opponents.where((o) => o.isActive).toList();

    if (heroFolded) {
      _showdownResult = 'You folded. Opponents win \$${_pot.toStringAsFixed(0)}.';
    } else if (activeOpponents.isEmpty) {
      // Everyone folded to hero
      _heroStack += _pot;
      _showdownResult = 'All opponents folded! You win \$${_pot.toStringAsFixed(0)}.';
    } else {
      // Simplified showdown: hero hand vs random determination for opponents
      // Hero always has evaluated hand; opponents get a rough strength score
      final heroStrength = getHandStrength();
      bool heroWins = true;
      for (final opp in activeOpponents) {
        // Opponent "hand strength" — weighted random by archetype aggression
        final oppStrength = _estimateOpponentStrength(opp);
        if (oppStrength > heroStrength) {
          heroWins = false;
          break;
        }
      }
      if (heroWins) {
        _heroStack += _pot;
        _showdownResult = 'You win \$${_pot.toStringAsFixed(0)} with ${_finalHand!.handName}!';
      } else {
        _showdownResult = 'Opponent wins. You lose \$${_pot.toStringAsFixed(0)}.';
      }
    }

    if (_currentHandId != null && _finalHand != null) {
      SessionService.completeHand(
        handId: _currentHandId!,
        communityCards: _communityCards,
        finalHand: _finalHand!.handName,
        handStrength: getHandStrength(),
        phaseReached: lastBettingPhase,
      );
    }
  }

  /// Rough opponent hand strength estimate based on their archetype behavior.
  /// Not a real hand eval — opponents don't have actual cards yet.
  double _estimateOpponentStrength(OpponentProfile opp) {
    final freqs = opp.archetype.freqs;
    final aggFactor = freqs['aggFactor'] ?? 2.5;
    final vpip = freqs['vpip'] ?? 0.22;

    // Tighter players (low VPIP) who stayed in tend to have stronger hands
    // Base strength scales inversely with VPIP — nits that stay in are dangerous
    final tightnessBonus = (1.0 - vpip) * 40; // nit=31, maniac=8
    final aggressionBonus = (aggFactor / 10.0) * 15; // maniac=12, nit=2

    // Random variance ±20
    final variance = (DateTime.now().microsecond % 40) - 20;

    return (tightnessBonus + aggressionBonus + variance).clamp(0, 100);
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
    _showdownResult = null;
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
