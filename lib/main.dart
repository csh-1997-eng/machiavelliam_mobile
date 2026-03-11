/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Entry point: main.dart
 * Purpose: App bootstrap, dark theme definition (Bellagio × Bloomberg), HomeScreen.
 */

import 'package:flutter/material.dart';
import 'models/game_settings.dart';
import 'screens/settings_screen.dart';
import 'screens/game_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scenario_screen.dart';

// App-wide palette
const _kBg = Color(0xFF0D0F13);
const _kSurface = Color(0xFF161921);
const _kBorder = Color(0xFF252833);
const _kGold = Color(0xFFB8963E);
const _kFeltGreen = Color(0xFF2A5C3F);
const _kTextPrimary = Color(0xFFDDDDDD);
const _kTextSecondary = Color(0xFF7A7A8A);
const _kDanger = Color(0xFFCF6679);

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
          primary: _kGold,
          onPrimary: _kBg,
          secondary: _kFeltGreen,
          onSecondary: _kTextPrimary,
          surface: _kSurface,
          onSurface: _kTextPrimary,
          error: _kDanger,
        ),
        scaffoldBackgroundColor: _kBg,
        cardTheme: CardTheme(
          color: _kSurface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _kBorder),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _kBg,
          foregroundColor: _kTextPrimary,
          centerTitle: true,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _kGold,
            foregroundColor: _kBg,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _kGold,
            side: const BorderSide(color: _kGold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _kGold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _kGold),
          ),
          hintStyle: const TextStyle(color: _kTextSecondary),
          filled: true,
          fillColor: _kSurface,
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: _kGold,
          thumbColor: _kGold,
          inactiveTrackColor: _kBorder,
          overlayColor: Color(0x30B8963E),
        ),
        dividerColor: _kBorder,
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? _kGold : _kTextSecondary,
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
        title: const Text(
          'MACHIAVELLIAM',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 3, color: _kGold),
        ),
      ),
      body: SingleChildScrollView(
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
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kGold.withOpacity(0.35)),
          ),
          child: const Icon(Icons.casino, size: 64, color: _kGold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Poker Learning',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _kTextPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'Read players. Exploit tendencies. Master the meta-game.',
          style: TextStyle(fontSize: 14, color: _kTextSecondary, height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettingsDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT SETUP',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kTextSecondary, letterSpacing: 1.2),
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
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => GameScreen(settings: _currentSettings)),
            ),
            child: const Text('Start Simulation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  initialSettings: _currentSettings,
                  onSettingsChanged: (s) => setState(() => _currentSettings = s),
                ),
              ),
            ),
            child: const Text('Configure Settings', style: TextStyle(fontSize: 15)),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ScenarioScreen()),
                  ),
                  child: const Text('Scenario Coach', style: TextStyle(fontSize: 14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                  child: const Text('Your Profile', style: TextStyle(fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ],
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FEATURES',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kTextSecondary, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('— ', style: TextStyle(color: _kGold, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                          children: [
                            TextSpan(text: f.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                            TextSpan(
                              text: '  ${f.$2}',
                              style: const TextStyle(color: _kTextSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: _kTextSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _kGold)),
      ],
    );
  }
}
