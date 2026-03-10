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
import '../controllers/poker_game_controller.dart';
import '../services/insights_service.dart';
import '../services/api_client.dart';

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
  String? _insightsText;
  final TextEditingController _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gameController = PokerGameController();
    _gameController.initializeGame(widget.settings);
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
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
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
            const SizedBox(height: 8),
            Text(
              _gameController.getPhaseDescription(),
              style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
          BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 2)),
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
                Text(phase, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            if (currentAction != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Recorded: ${currentAction.actionName.toUpperCase()}'
                  '${currentAction.amount != null ? '  \$${currentAction.amount!.toStringAsFixed(0)}' : ''}',
                  style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600),
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
                                backgroundColor: Colors.green[100],
                                side: BorderSide(color: Colors.green[700]!),
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
                              backgroundColor: Colors.green[100],
                              side: BorderSide(color: Colors.green[700]!),
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
    if (!kCoachingEnabled) {
      setState(() => _insightsText = 'Coaching not enabled yet.');
      return;
    }
    setState(() {
      _loadingInsights = true;
      _insightsText = null;
    });
    final result = await InsightsService.getInsights(
      userHoleCards: _gameController.userHoleCards,
      communityCards: _gameController.communityCards,
      currentEvaluation: _gameController.getCurrentHandEvaluation(),
      handStrengthPercent: _gameController.getHandStrength(),
      settings: _gameController.settings,
      phase: _gameController.currentPhase.name,
      playerAction: _gameController.currentPhaseAction,
      question: question,
    );
    if (mounted) {
      setState(() {
        _insightsText = result ?? 'No coaching available.';
        _loadingInsights = false;
      });
    }
  }

  Widget _buildCoachingPanel() {
    if (!_gameController.gameStarted) return const SizedBox.shrink();

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
                  onPressed: _loadingInsights ? null : () => _fetchInsights(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                  ),
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
                  color: Colors.green[800],
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
                        setState(() { _dealingHand = true; _insightsText = null; });
                        await _gameController.startNewHand();
                        if (mounted) setState(() => _dealingHand = false);
                      }
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], foregroundColor: Colors.white),
                child: _dealingHand
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
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
                        setState(() { _dealingHand = true; _insightsText = null; });
                        await _gameController.startNewHand();
                        if (mounted) setState(() => _dealingHand = false);
                      }
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600], foregroundColor: Colors.white),
                child: const Text('Reset Game'),
              ),
            ),
          ],
        ),
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
