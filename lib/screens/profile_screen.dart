/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Screen: profile_screen.dart
 * Purpose: Displays aggregated player stats — VPIP, PFR, aggression factor,
 *          positional tendencies, and detected leaks.
 */

import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PlayerProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!kProfileEnabled) {
      setState(() { _loading = false; _error = 'Profile not enabled yet.'; });
      return;
    }
    final profile = await ProfileService.getProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
        if (profile == null) _error = 'Could not load profile.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () { setState(() { _loading = true; _error = null; }); _loadProfile(); },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(fontSize: 16, color: Color(0xFF7A7A8A))))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final p = _profile!;

    if (p.totalHands < 5) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Play at least 5 hands to generate your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStyleCard(p),
          const SizedBox(height: 16),
          _buildStatsCard(p),
          const SizedBox(height: 16),
          if (p.leaks.isNotEmpty) _buildLeaksCard(p),
          if (p.leaks.isNotEmpty) const SizedBox(height: 16),
          if (p.byPosition.isNotEmpty) _buildPositionCard(p),
        ],
      ),
    );
  }

  Widget _buildStyleCard(PlayerProfile p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(p.style, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('${p.totalHands} hands', style: const TextStyle(fontSize: 14, color: Color(0xFF7A7A8A))),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _styleDescription(p.style),
              style: const TextStyle(fontSize: 14, color: Color(0xFF7A7A8A)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(PlayerProfile p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Key Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('VPIP', '${p.vpip}%', _vpipColor(p.vpip)),
                _buildStat('PFR', '${p.pfr}%', _pfrColor(p.pfr)),
                _buildStat('AF', p.aggressionFactor.toStringAsFixed(1), _afColor(p.aggressionFactor)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 4),
            Text(
              'VPIP: % hands voluntarily entering pot  •  PFR: % hands with preflop raise  •  AF: aggression factor',
              style: const TextStyle(fontSize: 11, color: Color(0xFF7A7A8A)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF7A7A8A), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildLeaksCard(PlayerProfile p) {
    return Card(
      color: const Color(0xFF2A1515),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF5C2A2A)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFCF6679), size: 20),
                const SizedBox(width: 8),
                const Text('Detected Leaks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFCF6679))),
              ],
            ),
            const SizedBox(height: 12),
            ...p.leaks.map((leak) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Color(0xFFCF6679), fontWeight: FontWeight.bold)),
                  Expanded(child: Text(leak, style: const TextStyle(fontSize: 14))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionCard(PlayerProfile p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('By Position', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFF252833)),
                  children: [
                    _tableHeader('Position'),
                    _tableHeader('Hands'),
                    _tableHeader('VPIP'),
                    _tableHeader('PFR'),
                  ],
                ),
                ...p.byPosition.map((row) => TableRow(
                  children: [
                    _tableCell(row['position'] as String),
                    _tableCell('${row['hands']}'),
                    _tableCell('${row['vpip']}%'),
                    _tableCell('${row['pfr']}%'),
                  ],
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7A7A8A))),
      );

  Widget _tableCell(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(text, style: const TextStyle(fontSize: 13)),
      );

  String _styleDescription(String style) {
    switch (style) {
      case 'Loose-aggressive (LAG)': return 'Plays many hands and bets/raises often. High variance, exploitable if undisciplined.';
      case 'Loose-passive': return 'Plays too many hands but rarely applies pressure. Classic fish pattern — overly calling.';
      case 'Tight-aggressive (TAG)': return 'Selective with starting hands, aggressive when in. Solid foundation for winning play.';
      case 'Tight-passive (nit)': return 'Plays very few hands and rarely bets. Missing value in good spots.';
      default: return 'No dominant pattern yet. Keep playing to build your profile.';
    }
  }

  Color _vpipColor(int vpip) {
    if (vpip < 15) return Colors.blue[700]!;
    if (vpip <= 30) return Colors.green[700]!;
    if (vpip <= 40) return Colors.orange[700]!;
    return Colors.red[700]!;
  }

  Color _pfrColor(int pfr) {
    if (pfr < 8) return Colors.red[700]!;
    if (pfr <= 20) return Colors.green[700]!;
    if (pfr <= 30) return Colors.orange[700]!;
    return Colors.red[700]!;
  }

  Color _afColor(double af) {
    if (af < 0.8) return Colors.red[700]!;
    if (af <= 3.0) return Colors.green[700]!;
    return Colors.orange[700]!;
  }
}
