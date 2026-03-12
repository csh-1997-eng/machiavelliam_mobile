/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Entry point: main.dart
 * Purpose: App bootstrap, dark theme definition, HomeScreen (the Foyer).
 */

import 'package:flutter/material.dart';
import 'models/game_settings.dart';
import 'theme/palazzo_colors.dart';
import 'screens/settings_screen.dart';
import 'screens/game_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scenario_screen.dart';
import 'screens/hand_history_screen.dart';

void main() {
  runApp(const PokerLearningApp());
}

class PokerLearningApp extends StatelessWidget {
  const PokerLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Machiavelliam',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: kGold,
          onPrimary: kBg,
          secondary: kFeltGreen,
          onSecondary: kTextPrimary,
          surface: kSurface,
          onSurface: kTextPrimary,
          error: kDanger,
        ),
        scaffoldBackgroundColor: kBg,
        cardTheme: CardThemeData(
          color: kSurface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: kBorder),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg,
          foregroundColor: kTextPrimary,
          centerTitle: true,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kGold,
            foregroundColor: kBg,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kGold,
            side: const BorderSide(color: kGold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: kGold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kGold),
          ),
          hintStyle: const TextStyle(color: kTextSecondary),
          filled: true,
          fillColor: kSurface,
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: kGold,
          thumbColor: kGold,
          inactiveTrackColor: kBorder,
          overlayColor: Color(0x30B8963E),
        ),
        dividerColor: kBorder,
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? kGold : kTextSecondary,
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameSettings _currentSettings = const GameSettings(
    numberOfPlayers: 6,
    userPosition: Position.middle,
    buyIn: 100,
    smallBlind: 1,
    bigBlind: 2,
    numberOfDecks: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWalnut,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/machiavelliam_logo.png', width: 28, height: 28),
            const SizedBox(width: 10),
            const Text(
              'MACHIAVELLIAM',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 3, color: kGold),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _FoyerBgPainter()),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHero(),
                const SizedBox(height: 24),
                _buildSettingsDisplay(),
                const SizedBox(height: 24),
                _buildActions(),
                const SizedBox(height: 24),
                _buildFeatures(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                kWalnutLight.withValues(alpha: 0.4),
                kWalnut.withValues(alpha: 0.6),
              ],
              radius: 1.2,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGold.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: kGold.withValues(alpha: 0.08),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset('assets/images/machiavelliam_logo.png', width: 88, height: 88),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Poker Learning',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kTextPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'Read players. Exploit tendencies. Master the meta-game.',
          style: TextStyle(fontSize: 14, color: kTextSecondary, height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettingsDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWalnut.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kWalnutLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT SETUP',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kTextSecondary, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSettingItem('Players', _currentSettings.numberOfPlayers.toString()),
              _buildSettingItem('Position', GameSettings.getPositionName(_currentSettings.userPosition)),
              _buildSettingItem(
                'Blinds',
                '\$${_currentSettings.smallBlind.toStringAsFixed(0)}/\$${_currentSettings.bigBlind.toStringAsFixed(0)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _woodButton(
          label: 'Start Simulation',
          isPrimary: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => GameScreen(settings: _currentSettings)),
          ),
        ),
        const SizedBox(height: 10),
        _woodButton(
          label: 'Configure Settings',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SettingsScreen(
                initialSettings: _currentSettings,
                onSettingsChanged: (s) => setState(() => _currentSettings = s),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _woodButton(
                label: 'Scenario Coach',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScenarioScreen()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _woodButton(
                label: 'Your Profile',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _woodButton(
                label: 'Hand History',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HandHistoryScreen()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _woodButton(
                label: 'Quick Start',
                onTap: _showQuickStart,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Coaching inputs may be used by OpenAI to improve AI models.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Color(0xFF4A4A5A), height: 1.4),
        ),
      ],
    );
  }

  Widget _woodButton({
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isPrimary
                ? [kWalnutLight, kWalnut]
                : [kSurface, kBg],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? kGold.withValues(alpha: 0.5) : kWalnutLight.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isPrimary ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: isPrimary ? kGold : kTextPrimary,
              letterSpacing: isPrimary ? 0.5 : 0,
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickStart() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kParchment,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (_) => const _QuickStartSheet(),
    );
  }

  Widget _buildFeatures() {
    const features = [
      ('Realistic Simulation', 'Full Texas Hold\'em hand flow with phase controls'),
      ('AI Coach', 'Machiavellian-level analysis at every decision point'),
      ('Ask the Coach', 'Free-form Q&A mid-hand'),
      ('Scenario Mode', 'Study any spot without a live hand'),
      ('Style Profile', 'VPIP, PFR, aggression factor — your tendencies surfaced'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FEATURES',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kTextSecondary, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        ...features.map((f) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBorder),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      decoration: const BoxDecoration(
                        color: kCrimson,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14, color: kTextPrimary),
                            children: [
                              TextSpan(text: f.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                              TextSpan(
                                text: '  ${f.$2}',
                                style: const TextStyle(color: kTextSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSettingItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: kTextSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kGold)),
      ],
    );
  }
}

// -- Subtle background texture for the foyer --

class _FoyerBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 24.0;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height * 0.3, size.height),
        Paint()
          ..color = kWalnutLight.withValues(alpha: 0.04)
          ..strokeWidth = 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Quick Start Sheet -- parchment-tinted
// ---------------------------------------------------------------------------

class _QuickStartSheet extends StatelessWidget {
  const _QuickStartSheet();

  static const _ink = Color(0xFF1A1A1A);
  static const _inkLight = Color(0xFF4A4A4A);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: kParchmentDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'QUICK START',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kCrimson, letterSpacing: 2),
          ),
          const SizedBox(height: 6),
          const Text(
            'Everything you need to play smart from hand one.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3, color: _ink),
          ),
          const SizedBox(height: 28),
          _section('THE LOOP', [
            _step('1', 'Configure your table', 'Set players, position, and buy-in in Settings. Your position is the single biggest variable in every decision you make — choose it deliberately.'),
            _step('2', 'Deal a hand', 'Tap Start Simulation \u2192 Deal Hand. Your hole cards are dealt. No action is required yet \u2014 read the board first.'),
            _step('3', 'Declare your action', 'Record what you actually did: Fold, Check, Call, or Bet. The coach needs your action to evaluate it \u2014 be honest.'),
            _step('4', 'Get coached', 'Tap Get Coaching. The AI breaks down your position, your range, and the board. Read it before you advance.'),
            _step('5', 'Advance the street', 'Deal Flop \u2192 Turn \u2192 River \u2192 Showdown. Repeat the action/coach cycle every street. That\u2019s where the learning compounds.'),
          ]),
          const SizedBox(height: 24),
          _section('COACHING MODES', [
            _bullet('GTO', 'Range-based. Frequency-correct. Position-aware. Use this when you want to understand the theoretically sound line \u2014 what a solver would do. Slow, rigorous, correct.'),
            _bullet('Exploit', 'Opponent-specific. The coach studies the reads you\u2019ve set on each player and tells you exactly how to deviate from GTO to punish their leaks. Use this when you have reads.'),
          ]),
          const SizedBox(height: 24),
          _section('OPPONENT READS', [
            _bullet('Set archetypes', 'In the Reads panel, each opponent gets a chip. Tap it to cycle their archetype. The coach and the AI engine both use this \u2014 it affects how opponents act and what coaching you receive.'),
            _bullet('Nit', 'Plays 13% of hands. Folds to everything. Steal relentlessly.'),
            _bullet('TAG', 'The default threat. Solid, position-aware, balanced. Respect their bets.'),
            _bullet('LAG', 'Bluffs often, plays wide, uses position. Tighten up and trap.'),
            _bullet('Station', 'Calls everything, never folds. Stop bluffing. Bet value all day.'),
            _bullet('Maniac', 'Bets 50%+ of hands, random sizings. Tighten, trap, let them hang.'),
          ]),
          const SizedBox(height: 24),
          _section('OTHER TOOLS', [
            _bullet('Scenario Coach', 'Study any spot outside a live hand. Paste in a hand history, describe a situation, ask a theoretical question. The coach has no ego about it.'),
            _bullet('Ask the Coach', 'Mid-hand Q&A. Type a specific question \u2014 stack-to-pot ratio, calling range, blocker effects \u2014 and get a direct answer. Use it.'),
            _bullet('Session Debrief', 'End Session \u2192 the coach reviews every decision you made and surfaces the patterns. This is where most players improve fastest.'),
            _bullet('Hand History', 'Browse past hands. Expand any of them, see your action trail, and hit Coach This Hand to drill a specific spot in Scenario Mode.'),
          ]),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kParchmentDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kCrimson.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'The game punishes passivity. Get in position. Make decisions. '
              'Let the coach tell you where you were wrong \u2014 then do it better next time.',
              style: TextStyle(
                fontSize: 13,
                color: _inkLight,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: kCrimson,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  static Widget _step(String num, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 1, right: 12),
            decoration: BoxDecoration(
              color: kGold,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _ink),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
                const SizedBox(height: 3),
                Text(body, style: const TextStyle(fontSize: 13, color: _inkLight, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _bullet(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('\u2014 ', style: TextStyle(color: kCrimson, fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: _ink, height: 1.5),
                children: [
                  TextSpan(text: '$title  ', style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: body, style: const TextStyle(color: _inkLight)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
