/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Screen: debrief_screen.dart
 * Purpose: Session retrospective UI — fetches AI debrief on mount, displays report card.
 */

import 'package:flutter/material.dart';
import '../services/debrief_service.dart';

class DebriefScreen extends StatefulWidget {
  final String sessionId;

  const DebriefScreen({super.key, required this.sessionId});

  @override
  State<DebriefScreen> createState() => _DebriefScreenState();
}

class _DebriefScreenState extends State<DebriefScreen> {
  String? _report;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _fetchDebrief();
  }

  Future<void> _fetchDebrief() async {
    final result = await DebriefService.getDebrief(sessionId: widget.sessionId);
    if (mounted) {
      setState(() {
        _report = result;
        _loading = false;
        _error = result == null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Debrief')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFFB8963E)),
                      SizedBox(height: 16),
                      Text(
                        'Analyzing your session...',
                        style: TextStyle(color: Color(0xFF7A7A8A)),
                      ),
                    ],
                  ),
                ),
              )
            : _error
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Column(
                        children: [
                          const Text('Could not load debrief.', style: TextStyle(color: Color(0xFF7A7A8A))),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              setState(() { _loading = true; _error = false; });
                              _fetchDebrief();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.analytics_outlined, color: Color(0xFFB8963E), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Session Report',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _report!,
                            style: const TextStyle(fontSize: 14, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
