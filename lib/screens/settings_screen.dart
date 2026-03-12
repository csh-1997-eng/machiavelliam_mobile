/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Screen: settings_screen.dart
 * Purpose: Palazzo-styled game configuration — walnut containers, gold-track
 *          sliders, visual table diagram for position selection.
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../theme/palazzo_colors.dart';

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
      appBar: AppBar(title: const Text('Game Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingCard('Players', Icons.people_outline, _buildPlayerCountSlider()),
            const SizedBox(height: 14),
            _buildSettingCard('Your Position', Icons.my_location, _buildPositionDiagram()),
            const SizedBox(height: 14),
            _buildSettingCard('Buy-in', Icons.attach_money, _buildBuyInSlider()),
            const SizedBox(height: 14),
            _buildSettingCard('Blinds', Icons.layers_outlined, _buildBlindStructure()),
            const SizedBox(height: 14),
            _buildSettingCard('Decks', Icons.style_outlined, _buildDeckCountSelector()),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(String title, IconData icon, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: kWalnutLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with crimson left accent
          Container(
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: kCrimson, width: 3)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: kGold, size: 18),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextPrimary)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: content,
          ),
        ],
      ),
    );
  }

  // ── Players slider ──

  Widget _buildPlayerCountSlider() {
    return Column(
      children: [
        SliderTheme(
          data: _goldSliderTheme(context),
          child: Slider(
            value: _currentSettings.numberOfPlayers.toDouble(),
            min: 2,
            max: 10,
            divisions: 8,
            label: _currentSettings.numberOfPlayers.toString(),
            onChanged: (value) {
              setState(() {
                _currentSettings = _currentSettings.copyWith(numberOfPlayers: value.round());
                final available = GameSettings.getAvailablePositions(_currentSettings.numberOfPlayers);
                if (!available.contains(_currentSettings.userPosition)) {
                  _currentSettings = _currentSettings.copyWith(userPosition: available.first);
                }
              });
            },
          ),
        ),
        Text(
          '${_currentSettings.numberOfPlayers} players',
          style: const TextStyle(fontSize: 15, color: kGold, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ── Position diagram ──

  Widget _buildPositionDiagram() {
    final available = GameSettings.getAvailablePositions(_currentSettings.numberOfPlayers);
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: CustomPaint(
            painter: _TableDiagramPainter(
              available: available,
              selected: _currentSettings.userPosition,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: _buildSeatButtons(constraints.biggest, available),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          GameSettings.getPositionName(_currentSettings.userPosition),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kGold),
        ),
        const SizedBox(height: 2),
        Text(
          GameSettings.getPositionDescription(_currentSettings.userPosition),
          style: const TextStyle(fontSize: 12, color: kTextSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _buildSeatButtons(Size size, List<Position> available) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = cx * 0.7;
    final ry = cy * 0.65;
    final widgets = <Widget>[];

    for (int i = 0; i < available.length; i++) {
      final angle = math.pi * 2 * i / available.length - math.pi / 2;
      final x = cx + rx * math.cos(angle) - 28;
      final y = cy + ry * math.sin(angle) - 14;
      final pos = available[i];
      final selected = pos == _currentSettings.userPosition;
      final label = _positionAbbrev(pos);

      widgets.add(
        Positioned(
          left: x,
          top: y,
          child: GestureDetector(
            onTap: () => setState(() {
              _currentSettings = _currentSettings.copyWith(userPosition: pos);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 28,
              decoration: BoxDecoration(
                color: selected ? kGold : kSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? kGold : kBorder,
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: kGold.withValues(alpha: 0.3), blurRadius: 8)]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected ? kBg : kTextSecondary,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  String _positionAbbrev(Position p) {
    switch (p) {
      case Position.smallBlind: return 'SB';
      case Position.bigBlind: return 'BB';
      case Position.early: return 'EP';
      case Position.middle: return 'MP';
      case Position.late: return 'LP';
      case Position.button: return 'BTN';
    }
  }

  // ── Buy-in slider ──

  Widget _buildBuyInSlider() {
    return Column(
      children: [
        SliderTheme(
          data: _goldSliderTheme(context),
          child: Slider(
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
        ),
        Text(
          '\$${_currentSettings.buyIn.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 15, color: kGold, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ── Blinds ──

  Widget _buildBlindStructure() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              const Text('Small Blind', style: TextStyle(fontSize: 12, color: kTextSecondary)),
              SliderTheme(
                data: _goldSliderTheme(context),
                child: Slider(
                  value: _currentSettings.smallBlind,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: '\$${_currentSettings.smallBlind.toStringAsFixed(0)}',
                  onChanged: (value) {
                    setState(() {
                      _currentSettings = _currentSettings.copyWith(
                        smallBlind: value,
                        bigBlind: value * 2,
                      );
                    });
                  },
                ),
              ),
              Text(
                '\$${_currentSettings.smallBlind.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, color: kGold, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 60,
          color: kBorder,
        ),
        Expanded(
          child: Column(
            children: [
              const Text('Big Blind', style: TextStyle(fontSize: 12, color: kTextSecondary)),
              SliderTheme(
                data: _goldSliderTheme(context),
                child: Slider(
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
              ),
              Text(
                '\$${_currentSettings.bigBlind.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, color: kGold, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Deck count ──

  Widget _buildDeckCountSelector() {
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: _goldSliderTheme(context),
            child: Slider(
              value: _currentSettings.numberOfDecks.toDouble(),
              min: 1,
              max: 8,
              divisions: 7,
              label: _currentSettings.numberOfDecks.toString(),
              onChanged: (value) {
                setState(() {
                  _currentSettings = _currentSettings.copyWith(numberOfDecks: value.round());
                });
              },
            ),
          ),
        ),
        Text(
          '${_currentSettings.numberOfDecks} deck${_currentSettings.numberOfDecks > 1 ? 's' : ''}',
          style: const TextStyle(fontSize: 15, color: kGold, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ── Action buttons ──

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
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
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kBorder),
              foregroundColor: kTextSecondary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Reset'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kWalnutLight, kWalnut],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGold.withValues(alpha: 0.4)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  widget.onSettingsChanged(_currentSettings);
                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Start Game',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kGold),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Gold slider theme ──

  static SliderThemeData _goldSliderTheme(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      activeTrackColor: kGold,
      inactiveTrackColor: kBorder,
      thumbColor: kGold,
      overlayColor: kGold.withValues(alpha: 0.15),
      valueIndicatorColor: kGold,
      valueIndicatorTextStyle: const TextStyle(color: kBg, fontWeight: FontWeight.bold),
    );
  }
}

// ── Table diagram painter ──

class _TableDiagramPainter extends CustomPainter {
  final List<Position> available;
  final Position selected;

  _TableDiagramPainter({required this.available, required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = cx * 0.75;
    final ry = cy * 0.7;

    // Baize fill
    final baizePaint = Paint()
      ..shader = RadialGradient(
        colors: [kBaizeLight, kBaize, kBaizeEdge],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), baizePaint);

    // Rail
    final railPaint = Paint()
      ..color = kCrimson
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), railPaint);

    // Gold stud dots on the rail
    final studPaint = Paint()..color = kGold.withValues(alpha: 0.5);
    for (int i = 0; i < 24; i++) {
      final angle = math.pi * 2 * i / 24;
      final sx = cx + rx * math.cos(angle);
      final sy = cy + ry * math.sin(angle);
      canvas.drawCircle(Offset(sx, sy), 1.5, studPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TableDiagramPainter old) =>
      old.selected != selected || old.available.length != available.length;
}
