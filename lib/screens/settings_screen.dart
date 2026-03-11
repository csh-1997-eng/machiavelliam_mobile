import 'package:flutter/material.dart';
import '../models/game_settings.dart';

class SettingsScreen extends StatefulWidget {
  final GameSettings initialSettings;
  final Function(GameSettings) onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.initialSettings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GameSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.initialSettings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingCard(
              'Number of Players',
              _buildPlayerCountSlider(),
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              'Your Position',
              _buildPositionSelector(),
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              'Buy-in Amount',
              _buildBuyInSelector(),
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              'Blind Structure',
              _buildBlindStructure(),
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              'Number of Decks',
              _buildDeckCountSelector(),
            ),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(String title, Widget content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCountSlider() {
    return Column(
      children: [
        Slider(
          value: _currentSettings.numberOfPlayers.toDouble(),
          min: 2,
          max: 10,
          divisions: 8,
          label: _currentSettings.numberOfPlayers.toString(),
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(
                numberOfPlayers: value.round(),
              );
              // Reset position if not available for new player count
              final availablePositions = GameSettings.getAvailablePositions(
                _currentSettings.numberOfPlayers,
              );
              if (!availablePositions.contains(_currentSettings.userPosition)) {
                _currentSettings = _currentSettings.copyWith(
                  userPosition: availablePositions.first,
                );
              }
            });
          },
        ),
        Text(
          '${_currentSettings.numberOfPlayers} players',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF7A7A8A),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionSelector() {
    final availablePositions = GameSettings.getAvailablePositions(
      _currentSettings.numberOfPlayers,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...availablePositions.map((position) => RadioListTile<Position>(
          title: Text(GameSettings.getPositionName(position)),
          subtitle: Text(
            GameSettings.getPositionDescription(position),
            style: TextStyle(fontSize: 12, color: const Color(0xFF7A7A8A)),
          ),
          value: position,
          groupValue: _currentSettings.userPosition,
          onChanged: (Position? value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(userPosition: value!);
            });
          },
        )),
      ],
    );
  }

  Widget _buildBuyInSelector() {
    return Column(
      children: [
        Slider(
          value: _currentSettings.buyIn,
          min: 10,
          max: 1000,
          divisions: 99,
          label: '\$${_currentSettings.buyIn.toStringAsFixed(0)}',
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(buyIn: value);
            });
          },
        ),
        Text(
          'Buy-in: \$${_currentSettings.buyIn.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF7A7A8A),
          ),
        ),
      ],
    );
  }

  Widget _buildBlindStructure() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text('Small Blind'),
                  Slider(
                    value: _currentSettings.smallBlind,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: '\$${_currentSettings.smallBlind.toStringAsFixed(0)}',
                    onChanged: (value) {
                      setState(() {
                        _currentSettings = _currentSettings.copyWith(
                          smallBlind: value,
                          bigBlind: value * 2, // Keep big blind as 2x small blind
                        );
                      });
                    },
                  ),
                  Text('\$${_currentSettings.smallBlind.toStringAsFixed(0)}'),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  Text('Big Blind'),
                  Slider(
                    value: _currentSettings.bigBlind,
                    min: 2,
                    max: 100,
                    divisions: 49,
                    label: '\$${_currentSettings.bigBlind.toStringAsFixed(0)}',
                    onChanged: (value) {
                      setState(() {
                        _currentSettings = _currentSettings.copyWith(bigBlind: value);
                      });
                    },
                  ),
                  Text('\$${_currentSettings.bigBlind.toStringAsFixed(0)}'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeckCountSelector() {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _currentSettings.numberOfDecks.toDouble(),
            min: 1,
            max: 8,
            divisions: 7,
            label: _currentSettings.numberOfDecks.toString(),
            onChanged: (value) {
              setState(() {
                _currentSettings = _currentSettings.copyWith(
                  numberOfDecks: value.round(),
                );
              });
            },
          ),
        ),
        Text(
          '${_currentSettings.numberOfDecks} deck${_currentSettings.numberOfDecks > 1 ? 's' : ''}',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF7A7A8A),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Reset to default settings
              setState(() {
                _currentSettings = const GameSettings(
                  numberOfPlayers: 6,
                  userPosition: Position.middle,
                  buyIn: 100,
                  smallBlind: 1,
                  bigBlind: 2,
                  numberOfDecks: 1,
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1D27),
              foregroundColor: const Color(0xFF7A7A8A),
            ),
            child: const Text('Reset to Default'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onSettingsChanged(_currentSettings);
              Navigator.of(context).pop();
            },
            child: const Text('Start Game'),
          ),
        ),
      ],
    );
  }
}
