/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Screen: scenario_screen.dart
 * Purpose: Hypothetical / study mode — free-form scenario input for
 *          pre-game prep, spot review, and range analysis without a live hand.
 */

import 'package:flutter/material.dart';
import '../services/insights_service.dart';
import '../services/profile_service.dart';
import '../services/api_client.dart';

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

    setState(() {
      _loading = true;
      _response = null;
    });

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
      appBar: AppBar(
        title: const Text('Scenario Coach'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputCard(),
            const SizedBox(height: 16),
            _buildExamplesCard(),
            if (_response != null) ...[
              const SizedBox(height: 16),
              _buildResponseCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Describe the Spot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Any situation — preflop, a specific board texture, a multi-street plan, a range question.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF7A7A8A)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _scenarioController,
              maxLines: 5,
              minLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. "I\'m on the button with AJo facing a 3-bet from a tight player in the CO..."',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitScenario,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                child: _loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(color: Color(0xFF0D0F13), strokeWidth: 2),
                      )
                    : const Text('Ask the Coach', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamplesCard() {
    return Card(
      color: const Color(0xFF161921),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Example Spots', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7A7A8A))),
            const SizedBox(height: 10),
            ..._exampleScenarios.map((ex) => GestureDetector(
                  onTap: () => setState(() => _scenarioController.text = ex),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right, size: 18, color: Color(0xFFB8963E)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ex,
                            style: const TextStyle(fontSize: 13, color: Color(0xFFDDDDDD)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 4),
            const Text('Tap any example to use it.', style: TextStyle(fontSize: 11, color: Color(0xFF7A7A8A))),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Color(0xFFB8963E), size: 20),
                const SizedBox(width: 8),
                const Text('Coach\'s Read', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(_response!, style: const TextStyle(fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
