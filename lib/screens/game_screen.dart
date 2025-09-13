import 'package:flutter/material.dart';
import '../models/card.dart' as poker;
import '../models/game_settings.dart';
import '../models/poker_hand.dart';
import '../controllers/poker_game_controller.dart';

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

  @override
  void initState() {
    super.initState();
    _gameController = PokerGameController();
    _gameController.initializeGame(widget.settings);
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
            onPressed: () {
              // Navigate back to settings
              Navigator.of(context).pop();
            },
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
            _buildPositionAdvice(            ),
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
                _buildInfoItem(
                  'Players',
                  _gameController.settings.numberOfPlayers.toString(),
                ),
                _buildInfoItem(
                  'Position',
                  GameSettings.getPositionName(_gameController.settings.userPosition),
                ),
                _buildInfoItem(
                  'Blinds',
                  '\$${_gameController.settings.smallBlind.toStringAsFixed(0)}/\$${_gameController.settings.bigBlind.toStringAsFixed(0)}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _gameController.getPhaseDescription(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityCards() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Community Cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _gameController.communityCards.isEmpty
                ? const Text(
                    'No community cards yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  )
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
            const Text(
              'Your Hole Cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _gameController.userHoleCards.isEmpty
                ? const Text(
                    'No hole cards dealt yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  )
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
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cardColor,
              ),
            ),
          ],
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
            const Text(
              'Hand Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
              if (_gameController.handComplete && _gameController.finalHand != null) ...[
                Text(
                  'Final Hand: ${_gameController.finalHand!.toString()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ] else ...[
              const Text(
                'Deal cards to see hand analysis',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
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
            const Text(
              'Position Advice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _gameController.getPositionAdvice(),
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
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
                onPressed: !_gameController.gameStarted
                    ? () {
                        setState(() {
                          _gameController.startNewHand();
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Deal Hand'),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
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
                onPressed: _gameController.gameStarted
                    ? () {
                        setState(() {
                          _gameController.startNewHand();
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  foregroundColor: Colors.white,
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
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                ),
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
