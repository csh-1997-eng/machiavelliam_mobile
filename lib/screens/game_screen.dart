/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Screen: game_screen.dart
 * Purpose: Main gameplay UI — cards, hand analysis, player action capture, phase controls.
 */

import 'package:flutter/material.dart';
import '../models/card.dart' as poker;
import '../models/game_settings.dart';
import '../models/poker_hand.dart';
import '../models/player_action.dart';
import '../models/opponent_profile.dart';
import '../controllers/poker_game_controller.dart';
import '../services/insights_service.dart';
import '../services/profile_service.dart';
import '../services/prompt_library.dart';
import '../utils/table_seating.dart';
import 'profile_screen.dart';
import 'debrief_screen.dart';

class GameScreen extends StatefulWidget {
  final GameSettings settings;

  const GameScreen({
    super.key,
    required this.settings,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late PokerGameController _gameController;
  bool _dealingHand = false;
  bool _loadingInsights = false;
  bool _insightsReceivedForPhase = false;
  String? _insightsText;
  String? _profileSummary;
  String _coachingMode = 'balanced';
  final TextEditingController _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gameController = PokerGameController();
    _gameController.initializeGame(widget.settings);
    _initOpponents();
    _loadProfile();
  }

  void _initOpponents() {
    final seats = TableSeating.seatLabels(
      widget.settings.numberOfPlayers,
      widget.settings.userPosition,
    );
    final opponents = seats
        .map((seat) => OpponentProfile(seatLabel: seat, stack: widget.settings.buyIn))
        .toList();
    _gameController.setOpponents(opponents);
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile();
    if (mounted && profile?.summary != null) {
      setState(() => _profileSummary = profile!.summary);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poker Hand Simulator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Your Profile',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGameInfo(),
            const SizedBox(height: 20),
            _buildCommunityCards(),
            const SizedBox(height: 20),
            _buildHoleCards(),
            const SizedBox(height: 20),
            _buildHandInfo(),
            const SizedBox(height: 20),
            _buildPlayerActionPanel(),
            const SizedBox(height: 20),
            _buildReadsPanel(),
            const SizedBox(height: 20),
            _buildCoachingPanel(),
            const SizedBox(height: 20),
            _buildPositionAdvice(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameInfo() {
    final showStack = _gameController.gameStarted;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem('Players', _gameController.settings.numberOfPlayers.toString()),
                _buildInfoItem('Position', GameSettings.getPositionName(_gameController.settings.userPosition)),
                _buildInfoItem(
                  'Blinds',
                  '\$${_gameController.settings.smallBlind.toStringAsFixed(0)}/\$${_gameController.settings.bigBlind.toStringAsFixed(0)}',
                ),
              ],
            ),
            if (showStack) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem('Pot', '\$${_gameController.pot.toStringAsFixed(0)}'),
                  _buildInfoItem('Stack', '\$${_gameController.heroStack.toStringAsFixed(0)}'),
                  _buildInfoItem('SPR', _gameController.spr.toStringAsFixed(1)),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              _gameController.getPhaseDescription(),
              style: const TextStyle(fontSize: 16, color: Color(0xFF7A7A8A), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF7A7A8A))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCommunityCards() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Community Cards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _gameController.communityCards.isEmpty
                ? const Text('No community cards yet', style: TextStyle(fontSize: 16, color: Colors.grey))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _gameController.communityCards
                        .map((card) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: _buildCard(card),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoleCards() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Your Hole Cards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _gameController.userHoleCards.isEmpty
                ? const Text('No hole cards dealt yet', style: TextStyle(fontSize: 16, color: Colors.grey))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _gameController.userHoleCards
                        .map((card) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: _buildCard(card),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(poker.PokerCard card) {
    Color cardColor = card.color == 'red' ? Colors.red : Colors.black;
    return Container(
      width: 60,
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.3), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Text(
          card.displayName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cardColor),
        ),
      ),
    );
  }

  Widget _buildHandInfo() {
    PokerHand? currentHand = _gameController.getCurrentHandEvaluation();
    double handStrength = _gameController.getHandStrength();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Hand Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (currentHand != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem('Hand', currentHand.handName),
                  _buildInfoItem('Strength', '${handStrength.toStringAsFixed(0)}%'),
                ],
              ),
              const SizedBox(height: 8),
              if (_gameController.handComplete && _gameController.finalHand != null)
                Text(
                  'Final Hand: ${_gameController.finalHand!.toString()}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
            ] else ...[
              const Text('Deal cards to see hand analysis', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  /// Action capture panel — visible whenever a hand is in progress (not showdown).
  Widget _buildPlayerActionPanel() {
    if (!_gameController.gameStarted || _gameController.handComplete) {
      return const SizedBox.shrink();
    }

    final currentAction = _gameController.currentPhaseAction;
    final phase = _gameController.currentPhase.name.toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your Action', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(phase, style: const TextStyle(fontSize: 12, color: Color(0xFF7A7A8A), fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            if (currentAction != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Recorded: ${currentAction.actionName.toUpperCase()}'
                  '${currentAction.amount != null ? '  \$${currentAction.amount!.toStringAsFixed(0)}' : ''}',
                  style: const TextStyle(color: Color(0xFFB8963E), fontWeight: FontWeight.w600),
                ),
              ),
            Row(
              children: [
                for (final action in [ActionType.fold, ActionType.check, ActionType.call])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: OutlinedButton(
                        onPressed: () => _recordAction(action),
                        style: currentAction?.action == action
                            ? OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A3A2A),
                                side: const BorderSide(color: Color(0xFFB8963E)),
                              )
                            : null,
                        child: Text(action.name.toUpperCase(), style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: OutlinedButton(
                      onPressed: () => _showBetDialog(),
                      style: currentAction?.action == ActionType.bet
                          ? OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A3A2A),
                              side: const BorderSide(color: Color(0xFFB8963E)),
                            )
                          : null,
                      child: const Text('BET', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _recordAction(ActionType action, {double? amount}) {
    setState(() {
      _gameController.recordAction(action, amount: amount);
    });
  }

  void _showBetDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bet Amount'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '\$', hintText: '0'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              _recordAction(ActionType.bet, amount: amount);
              Navigator.pop(ctx);
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchInsights({String? question}) async {
    setState(() {
      _loadingInsights = true;
      _insightsText = null;
    });
    final opponents = _gameController.opponents;
    final result = await InsightsService.getInsights(
      userHoleCards: _gameController.userHoleCards,
      communityCards: _gameController.communityCards,
      currentEvaluation: _gameController.getCurrentHandEvaluation(),
      handStrengthPercent: _gameController.getHandStrength(),
      settings: _gameController.settings,
      phase: _gameController.currentPhase.name,
      playerAction: _gameController.currentPhaseAction,
      question: question,
      profileSummary: _profileSummary,
      coachingMode: _coachingMode,
      opponents: opponents.map((o) => o.toJson()).toList(),
      pot: _gameController.pot,
      heroStack: _gameController.heroStack,
      spr: _gameController.spr,
      previousResponseId: InsightsService.lastResponseId,
    );
    if (mounted) {
      setState(() {
        _insightsText = result ?? 'No coaching available.';
        _loadingInsights = false;
        // Lock "Get Coaching" for this phase — questions still allowed
        if (question == null) _insightsReceivedForPhase = true;
      });
    }
  }

  Widget _buildCoachingPanel() {
    if (!_gameController.gameStarted) return const SizedBox.shrink();

    final canGetCoaching = !_loadingInsights && !_insightsReceivedForPhase;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('AI Coach', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: canGetCoaching ? () => _fetchInsights() : null,
                  child: _loadingInsights
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Get Coaching'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // GTO / Exploit toggle — always interactive (affects next coaching call)
            Row(
              children: [
                for (final mode in ['balanced', 'exploit'])
                  GestureDetector(
                    onTap: () => setState(() => _coachingMode = mode),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _coachingMode == mode ? const Color(0xFFB8963E) : const Color(0xFF252833),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        mode == 'balanced' ? 'GTO' : 'Exploit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _coachingMode == mode ? const Color(0xFF0D0F13) : const Color(0xFF7A7A8A),
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                const Text(
                  'MODE',
                  style: TextStyle(fontSize: 10, color: Color(0xFF7A7A8A), letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      hintText: 'Ask the coach anything...',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onSubmitted: (q) {
                      if (q.trim().isNotEmpty) {
                        _fetchInsights(question: q.trim());
                        _questionController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loadingInsights
                      ? null
                      : () {
                          final q = _questionController.text.trim();
                          if (q.isNotEmpty) {
                            _fetchInsights(question: q);
                            _questionController.clear();
                          }
                        },
                  icon: const Icon(Icons.send),
                  color: const Color(0xFFB8963E),
                ),
              ],
            ),
            if (_insightsText != null) ...[
              const SizedBox(height: 12),
              Text(_insightsText!, style: const TextStyle(fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }

  /// Opponent reads panel — visible once a hand is in progress.
  /// Chip per seat: tap to cycle archetype. Gold text on last action.
  Widget _buildReadsPanel() {
    if (!_gameController.gameStarted) return const SizedBox.shrink();
    final opponents = _gameController.opponents;
    if (opponents.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reads', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: opponents.map((opp) => _buildOpponentChip(opp)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpponentChip(OpponentProfile opp) {
    final isActive = opp.isActive;
    final action = opp.lastAction;

    return GestureDetector(
      onTap: () {
        if (!isActive) return;
        setState(() {
          // Cycle through archetypes
          final keys = kArchetypeOrder;
          final currentIdx = keys.indexOf(opp.archetype.apiKey);
          final nextKey = keys[(currentIdx + 1) % keys.length];
          opp.archetype = PlayerArchetype.values.firstWhere((a) => a.apiKey == nextKey);
        });
      },
      child: Opacity(
        opacity: isActive ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D27),
            border: Border.all(
              color: isActive ? const Color(0xFF252833) : const Color(0xFF1A1D27),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                opp.seatLabel,
                style: const TextStyle(fontSize: 11, color: Color(0xFF7A7A8A), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                opp.archetype.label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${opp.stack.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF7A7A8A)),
              ),
              if (action != null)
                Text(
                  action.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB8963E),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPositionAdvice() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Position Advice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(_gameController.getPositionAdvice(), style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: !_gameController.gameStarted && !_dealingHand
                    ? () async {
                        setState(() { _dealingHand = true; _insightsText = null; _insightsReceivedForPhase = false; });
                        await _gameController.startNewHand();
                        if (mounted) setState(() => _dealingHand = false);
                      }
                    : null,
                child: _dealingHand
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(color: Color(0xFF0D0F13), strokeWidth: 2),
                      )
                    : const Text('Deal Hand'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _gameController.gameStarted &&
                        !_gameController.handComplete &&
                        _gameController.canProceedToNextPhase()
                    ? () {
                        setState(() {
                          _gameController.advanceToNextPhase();
                          _insightsReceivedForPhase = false;
                          _insightsText = null;
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A2A),
                  foregroundColor: const Color(0xFFDDDDDD),
                ),
                child: Text(_getNextPhaseButtonText()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _gameController.gameStarted && !_dealingHand
                    ? () async {
                        setState(() { _dealingHand = true; _insightsText = null; _insightsReceivedForPhase = false; });
                        await _gameController.startNewHand();
                        if (mounted) setState(() => _dealingHand = false);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF252833),
                  foregroundColor: const Color(0xFFDDDDDD),
                ),
                child: const Text('New Hand'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _gameController.resetGame();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1D27),
                  foregroundColor: const Color(0xFF7A7A8A),
                ),
                child: const Text('Reset Game'),
              ),
            ),
          ],
        ),
        if (_gameController.gameStarted) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                final sessionId = _gameController.sessionId;
                if (sessionId == null) return;
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DebriefScreen(sessionId: sessionId)),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7A7A8A),
                side: const BorderSide(color: Color(0xFF252833)),
              ),
              child: const Text('End Session'),
            ),
          ),
        ],
      ],
    );
  }

  String _getNextPhaseButtonText() {
    switch (_gameController.currentPhase) {
      case GamePhase.preflop:
        return 'Deal Flop';
      case GamePhase.flop:
        return 'Deal Turn';
      case GamePhase.turn:
        return 'Deal River';
      case GamePhase.river:
        return 'Showdown';
      case GamePhase.showdown:
        return 'Complete';
    }
  }
}
