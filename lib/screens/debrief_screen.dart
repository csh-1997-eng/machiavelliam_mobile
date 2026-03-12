/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Screen: debrief_screen.dart
 * Purpose: Palazzo-styled session debrief — parchment "letter" container
 *          with slight rotation and wax seal icon.
 */

import 'package:flutter/material.dart';
import '../services/debrief_service.dart';
import '../theme/palazzo_colors.dart';

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
        padding: const EdgeInsets.all(20),
        child: _loading
            ? _buildLoading()
            : _error
                ? _buildError()
                : _buildLetter(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80),
        child: Column(
          children: [
            CircularProgressIndicator(color: kGold),
            SizedBox(height: 16),
            Text('Analyzing your session...', style: TextStyle(color: kTextSecondary, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: kDanger, size: 36),
            const SizedBox(height: 12),
            const Text('Could not load debrief.', style: TextStyle(color: kTextSecondary)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() { _loading = true; _error = false; });
                _fetchDebrief();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kGold),
                foregroundColor: kGold,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Parchment letter with wax seal ──

  Widget _buildLetter() {
    return Center(
      child: Transform.rotate(
        angle: -0.008, // subtle tilt
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: kParchment,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(4, 6),
              ),
              BoxShadow(
                color: kWalnut.withValues(alpha: 0.3),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Aged paper edge effect
              Positioned.fill(
                child: CustomPaint(painter: _PaperEdgePainter()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with seal
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SESSION REPORT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: kCrimson,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(height: 1, width: 80, color: kCrimson.withValues(alpha: 0.4)),
                            ],
                          ),
                        ),
                        // Wax seal
                        _buildWaxSeal(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Report body
                    Text(
                      _report!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: Color(0xFF2A2A2A),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Footer rule
                    Container(height: 1, color: kParchmentDark),
                    const SizedBox(height: 8),
                    const Text(
                      'Machiavelliam \u2022 Post-Session Analysis',
                      style: TextStyle(fontSize: 10, color: Color(0xFF8A8A8A), letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaxSeal() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            kCrimsonLight,
            kCrimson,
            kCrimson.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset('assets/images/machiavelliam_logo.png', width: 36, height: 36, fit: BoxFit.cover),
      ),
    );
  }
}

// ── Subtle aged-paper edge staining ──

class _PaperEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final edgePaint = Paint()
      ..color = kParchmentDark.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Inner border line (slightly inset)
    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas.drawRect(rect, edgePaint);

    // Corner embellishments
    final cornerPaint = Paint()
      ..color = kCrimson.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const cs = 12.0;
    // Top-left
    canvas.drawLine(const Offset(8, 8), const Offset(8 + cs, 8), cornerPaint);
    canvas.drawLine(const Offset(8, 8), const Offset(8, 8 + cs), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(size.width - 8, 8), Offset(size.width - 8 - cs, 8), cornerPaint);
    canvas.drawLine(Offset(size.width - 8, 8), Offset(size.width - 8, 8 + cs), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(8, size.height - 8), Offset(8 + cs, size.height - 8), cornerPaint);
    canvas.drawLine(Offset(8, size.height - 8), Offset(8, size.height - 8 - cs), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - 8, size.height - 8), Offset(size.width - 8 - cs, size.height - 8), cornerPaint);
    canvas.drawLine(Offset(size.width - 8, size.height - 8), Offset(size.width - 8, size.height - 8 - cs), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
