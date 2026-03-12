/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Screen: scenario_screen.dart
 * Purpose: Palazzo-styled scenario coach — parchment textarea with ink
 *          placeholder, book-icon example rows, walnut containers.
 */

import 'package:flutter/material.dart';
import '../services/insights_service.dart';
import '../services/profile_service.dart';
import '../services/api_client.dart';
import '../theme/palazzo_colors.dart';

class ScenarioScreen extends StatefulWidget {
  final String? initialScenario;

  const ScenarioScreen({super.key, this.initialScenario});

  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  final TextEditingController _scenarioController = TextEditingController();
  bool _loading = false;
  String? _response;
  String? _profileSummary;

  static const _exampleScenarios = [
    "I'm on the button with AJo, 6-handed. A tight-aggressive player in MP raises 3x and the CO calls. Do I 3-bet, call, or fold?",
    "Hero is in the BB with 77. UTG opens 2.5x, everyone folds. Flop comes K-9-2 rainbow. UTG c-bets 50% pot. What's my plan for all three streets?",
    "I 3-bet a LAG from the CO with KQs. He calls in position. Flop is Q-7-2 with two clubs. What's my default line?",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialScenario != null) {
      _scenarioController.text = widget.initialScenario!;
    }
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile();
    if (mounted && profile?.summary != null) {
      setState(() => _profileSummary = profile!.summary);
    }
  }

  @override
  void dispose() {
    _scenarioController.dispose();
    super.dispose();
  }

  Future<void> _submitScenario() async {
    final scenario = _scenarioController.text.trim();
    if (scenario.isEmpty) return;

    if (!kScenarioEnabled) {
      setState(() => _response = 'Scenario coaching not enabled yet.');
      return;
    }

    setState(() { _loading = true; _response = null; });

    final result = await InsightsService.getScenarioInsights(
      scenario: scenario,
      profileSummary: _profileSummary,
    );

    if (mounted) {
      setState(() {
        _response = result ?? 'No response available.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scenario Coach')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputCard(),
            const SizedBox(height: 14),
            _buildExamplesCard(),
            if (_response != null) ...[
              const SizedBox(height: 14),
              _buildResponseCard(),
            ],
          ],
        ),
      ),
    );
  }

  // ── Parchment-tinted input card ──

  Widget _buildInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: kWalnutLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_stories, color: kGold, size: 18),
              SizedBox(width: 8),
              Text('Describe the Spot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextPrimary)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Any situation \u2014 preflop, a specific board texture, a multi-street plan, a range question.',
            style: TextStyle(fontSize: 12, color: kTextSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: kParchment.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBorder),
            ),
            child: TextField(
              controller: _scenarioController,
              maxLines: 5,
              minLines: 3,
              style: const TextStyle(fontSize: 14, color: kTextPrimary, height: 1.5),
              decoration: InputDecoration(
                hintText: 'e.g. "I\'m on the button with AJo facing a 3-bet from a tight player in the CO..."',
                hintStyle: TextStyle(fontSize: 13, color: kTextSecondary.withValues(alpha: 0.6), fontStyle: FontStyle.italic),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
              textInputAction: TextInputAction.newline,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
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
                  onTap: _loading ? null : _submitScenario,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _loading
                        ? const Center(
                            child: SizedBox(
                              height: 16, width: 16,
                              child: CircularProgressIndicator(color: kGold, strokeWidth: 2),
                            ),
                          )
                        : const Text(
                            'Ask the Coach',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kGold),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Example spots with book icons ──

  Widget _buildExamplesCard() {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book, color: kTextSecondary, size: 16),
              SizedBox(width: 6),
              Text('Example Spots', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kTextSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          ..._exampleScenarios.map((ex) => GestureDetector(
            onTap: () => setState(() => _scenarioController.text = ex),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bookmark_outline, size: 16, color: kGold),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      ex,
                      style: const TextStyle(fontSize: 13, color: kTextPrimary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          )),
          const Text('Tap any example to use it.', style: TextStyle(fontSize: 11, color: kTextSecondary)),
        ],
      ),
    );
  }

  // ── Response card ──

  Widget _buildResponseCard() {
    return Container(
      decoration: BoxDecoration(
        color: kWalnutLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGold.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: kGold, size: 20),
              SizedBox(width: 8),
              Text('Coach\'s Read', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kGold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_response!, style: const TextStyle(fontSize: 14, height: 1.6, color: kTextPrimary)),
        ],
      ),
    );
  }
}
