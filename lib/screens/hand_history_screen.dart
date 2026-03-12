/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Screen: hand_history_screen.dart
 * Purpose: Browsable hand history — paginated list of past hands with expand/collapse
 *          and "Coach this hand" CTA that pre-populates ScenarioScreen.
 */

import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../services/api_client.dart';
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
    final sessionId = widget.sessionId;
    if (sessionId == null) {
      setState(() => _loading = false);
      return;
    }
    final result = await HistoryService.getHistory(sessionId: sessionId, page: _page);
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
              child: Text(
                'Hand history is not enabled.',
                style: TextStyle(color: Color(0xFF7A7A8A)),
              ),
            )
          : _hands.isEmpty && !_loading
              ? const Center(
                  child: Text(
                    'No hands recorded for this session.',
                    style: TextStyle(color: Color(0xFF7A7A8A)),
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
                          child: CircularProgressIndicator(color: Color(0xFFB8963E)),
                        ),
                      );
                    }
                    if (index == _hands.length && _hasMore) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: OutlinedButton(
                          onPressed: _loading ? null : _loadMore,
                          child: _loading
                              ? const SizedBox(
                                  height: 14, width: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
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
    final board = hand.communityCards.isNotEmpty ? hand.communityCards.join(' ') : '—';
    final phase = hand.phaseReached?.toUpperCase() ?? 'PREFLOP';
    final result = hand.finalHand ?? '—';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      holeCards,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D27),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      phase,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF7A7A8A), fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF7A7A8A),
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Board: $board',
                style: const TextStyle(fontSize: 13, color: Color(0xFF7A7A8A)),
              ),
              if (isExpanded) ...[
                const SizedBox(height: 10),
                const Divider(color: Color(0xFF252833), height: 1),
                const SizedBox(height: 10),
                Text(
                  result,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB8963E),
                  ),
                ),
                const SizedBox(height: 8),
                ...hand.actions.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            a.phase.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF7A7A8A), fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            a.action.toUpperCase(),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          if (a.amount != null)
                            Text(
                              '  \$${a.amount!.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF7A7A8A)),
                            ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
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
                    icon: const Icon(Icons.smart_toy_outlined, size: 16, color: Color(0xFFB8963E)),
                    label: const Text(
                      'Coach this hand',
                      style: TextStyle(color: Color(0xFFB8963E), fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
