/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Screen: hand_history_screen.dart
 * Purpose: Palazzo-styled hand history browser — walnut cards, action timeline
 *          with gold phase dots, quill "Coach this hand" CTA.
 */

import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../services/api_client.dart';
import '../theme/palazzo_colors.dart';
import 'scenario_screen.dart';

class HandHistoryScreen extends StatefulWidget {
  final String? sessionId;

  const HandHistoryScreen({super.key, this.sessionId});

  @override
  State<HandHistoryScreen> createState() => _HandHistoryScreenState();
}

class _HandHistoryScreenState extends State<HandHistoryScreen> {
  final List<HandHistoryRecord> _hands = [];
  bool _loading = true;
  bool _hasMore = false;
  int _page = 0;
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (!kHistoryEnabled) {
      setState(() => _loading = false);
      return;
    }
    final result = await HistoryService.getHistory(sessionId: widget.sessionId, page: _page);
    if (mounted) {
      setState(() {
        _hands.addAll(result.hands);
        _hasMore = result.hasMore;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() { _page++; _loading = true; });
    await _loadPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hand History')),
      body: !kHistoryEnabled
          ? const Center(
              child: Text('Hand history is not enabled.', style: TextStyle(color: kTextSecondary)),
            )
          : _hands.isEmpty && !_loading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, color: kGold.withValues(alpha: 0.4), size: 48),
                      const SizedBox(height: 12),
                      const Text('No hands recorded for this session.', style: TextStyle(color: kTextSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _hands.length + (_hasMore ? 1 : 0) + (_loading && _hands.isEmpty ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_loading && _hands.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: CircularProgressIndicator(color: kGold),
                        ),
                      );
                    }
                    if (index == _hands.length && _hasMore) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: OutlinedButton(
                          onPressed: _loading ? null : _loadMore,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kGold),
                            foregroundColor: kGold,
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 14, width: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: kGold),
                                )
                              : const Text('Load More'),
                        ),
                      );
                    }
                    return _buildHandCard(_hands[index]);
                  },
                ),
    );
  }

  Widget _buildHandCard(HandHistoryRecord hand) {
    final isExpanded = _expanded.contains(hand.id);
    final holeCards = hand.holeCards.join(' ');
    final board = hand.communityCards.isNotEmpty ? hand.communityCards.join(' ') : '\u2014';
    final phase = hand.phaseReached?.toUpperCase() ?? 'PREFLOP';
    final result = hand.finalHand ?? '\u2014';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: kWalnutLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isExpanded ? kGold.withValues(alpha: 0.4) : kBorder),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() {
            if (isExpanded) {
              _expanded.remove(hand.id);
            } else {
              _expanded.add(hand.id);
            }
          }),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        holeCards,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextPrimary),
                      ),
                    ),
                    _phaseBadge(phase),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: kTextSecondary,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Board: $board',
                  style: const TextStyle(fontSize: 13, color: kTextSecondary),
                ),

                // Expanded section
                if (isExpanded) ...[
                  const SizedBox(height: 10),
                  Container(height: 1, color: kBorder),
                  const SizedBox(height: 10),
                  // Final hand result
                  Text(
                    result,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kGold),
                  ),
                  const SizedBox(height: 12),
                  // Action timeline with gold dots
                  ...hand.actions.map((a) => _buildActionRow(a)),
                  const SizedBox(height: 12),
                  // Coach this hand CTA
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ScenarioScreen(initialScenario: hand.toScenarioString()),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_note, size: 18, color: kGold),
                      label: const Text(
                        'Coach this hand',
                        style: TextStyle(color: kGold, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _phaseBadge(String phase) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: kBorder),
      ),
      child: Text(
        phase,
        style: const TextStyle(fontSize: 10, color: kGold, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildActionRow(HandAction a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Gold phase dot with connecting line
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kGold,
                    border: Border.all(color: kGold.withValues(alpha: 0.5), width: 2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 60,
            child: Text(
              a.phase.toUpperCase(),
              style: const TextStyle(fontSize: 11, color: kTextSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            a.action.toUpperCase(),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kTextPrimary),
          ),
          if (a.amount != null)
            Text(
              '  \$${a.amount!.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 13, color: kGold),
            ),
        ],
      ),
    );
  }
}
