/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Screen: profile_screen.dart
 * Purpose: Palazzo-styled player profile — gold fill bars for stats,
 *          crimson leak warnings, walnut containers.
 */

import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/api_client.dart';
import '../theme/palazzo_colors.dart';

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
            icon: const Icon(Icons.refresh, color: kGold),
            onPressed: () { setState(() { _loading = true; _error = null; }); _loadProfile(); },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kGold))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(fontSize: 16, color: kTextSecondary)))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final p = _profile!;

    if (p.totalHands < 5) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_empty, color: kGold.withValues(alpha: 0.5), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Play at least 5 hands to generate your profile.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: kTextSecondary),
              ),
            ],
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
          const SizedBox(height: 14),
          _buildStatsCard(p),
          if (p.leaks.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildLeaksCard(p),
          ],
          if (p.byPosition.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildPositionCard(p),
          ],
        ],
      ),
    );
  }

  // ── Style card ──

  Widget _buildStyleCard(PlayerProfile p) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kWalnutLight, kWalnut],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGold.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(p.style, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kGold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${p.totalHands} hands', style: const TextStyle(fontSize: 12, color: kTextSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _styleDescription(p.style),
            style: const TextStyle(fontSize: 13, color: kTextPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ── Stats with gold fill bars ──

  Widget _buildStatsCard(PlayerProfile p) {
    return _walnutCard(
      icon: Icons.bar_chart,
      title: 'Key Stats',
      child: Column(
        children: [
          _buildStatBar('VPIP', p.vpip.toDouble(), 100, '${p.vpip}%', _vpipColor(p.vpip)),
          const SizedBox(height: 14),
          _buildStatBar('PFR', p.pfr.toDouble(), 100, '${p.pfr}%', _pfrColor(p.pfr)),
          const SizedBox(height: 14),
          _buildStatBar('AF', p.aggressionFactor, 5.0, p.aggressionFactor.toStringAsFixed(1), _afColor(p.aggressionFactor)),
          const SizedBox(height: 14),
          const Divider(color: kBorder, height: 1),
          const SizedBox(height: 8),
          const Text(
            'VPIP: % hands entering pot  \u2022  PFR: % preflop raises  \u2022  AF: aggression factor',
            style: TextStyle(fontSize: 11, color: kTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, double value, double max, String display, Color color) {
    final pct = (value / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kTextSecondary)),
            Text(display, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: kBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  // ── Leaks — crimson card ──

  Widget _buildLeaksCard(PlayerProfile p) {
    return Container(
      decoration: BoxDecoration(
        color: kCrimson.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCrimson.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: kDanger, size: 20),
              SizedBox(width: 8),
              Text('Detected Leaks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kDanger)),
            ],
          ),
          const SizedBox(height: 12),
          ...p.leaks.map((leak) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('\u2022 ', style: TextStyle(color: kDanger, fontWeight: FontWeight.bold)),
                Expanded(child: Text(leak, style: const TextStyle(fontSize: 13, color: kParchment, height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ── Position breakdown ──

  Widget _buildPositionCard(PlayerProfile p) {
    return _walnutCard(
      icon: Icons.grid_on,
      title: 'By Position',
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: kBg.withValues(alpha: 0.5)),
            children: [
              _tableHeader('Position'),
              _tableHeader('Hands'),
              _tableHeader('VPIP'),
              _tableHeader('PFR'),
            ],
          ),
          ...p.byPosition.map((row) => TableRow(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kBorder, width: 0.5))),
            children: [
              _tableCell(row['position'] as String, bold: true),
              _tableCell('${row['hands']}'),
              _tableCell('${row['vpip']}%'),
              _tableCell('${row['pfr']}%'),
            ],
          )),
        ],
      ),
    );
  }

  // ── Shared walnut card ──

  Widget _walnutCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: kWalnutLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: kCrimson, width: 3)),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
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
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kGold)),
  );

  Widget _tableCell(String text, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    child: Text(text, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w600 : FontWeight.normal, color: kTextPrimary)),
  );

  String _styleDescription(String style) {
    switch (style) {
      case 'Loose-aggressive (LAG)': return 'Plays many hands and bets/raises often. High variance, exploitable if undisciplined.';
      case 'Loose-passive': return 'Plays too many hands but rarely applies pressure. Classic fish pattern \u2014 overly calling.';
      case 'Tight-aggressive (TAG)': return 'Selective with starting hands, aggressive when in. Solid foundation for winning play.';
      case 'Tight-passive (nit)': return 'Plays very few hands and rarely bets. Missing value in good spots.';
      default: return 'No dominant pattern yet. Keep playing to build your profile.';
    }
  }

  Color _vpipColor(int vpip) {
    if (vpip <= 30) return kGold;
    if (vpip <= 40) return const Color(0xFFCC8833);
    return kDanger;
  }

  Color _pfrColor(int pfr) {
    if (pfr < 8) return kDanger;
    if (pfr <= 20) return kGold;
    if (pfr <= 30) return const Color(0xFFCC8833);
    return kDanger;
  }

  Color _afColor(double af) {
    if (af < 0.8) return kDanger;
    if (af <= 3.0) return kGold;
    return const Color(0xFFCC8833);
  }
}
