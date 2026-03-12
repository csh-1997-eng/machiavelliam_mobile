/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Widget: felt_table.dart
 * Purpose: Renaissance palazzo poker table — walnut rim, crimson leather
 *          rail, emerald baize center with candlelit radial vignette.
 */

import 'package:flutter/material.dart';
import '../theme/palazzo_colors.dart';

class FeltTable extends StatelessWidget {
  final Widget child;
  final double? height;

  const FeltTable({
    super.key,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: kWalnut,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kWalnutLight, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x60000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Walnut outer wood
            Positioned.fill(
              child: Container(color: kWalnut),
            ),
            // Crimson leather rail
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kCrimson,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: kCrimsonLight.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                ),
              ),
            ),
            // Gold stud trim (painted dots along rail)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(8),
                child: CustomPaint(
                  painter: _StudTrimPainter(),
                ),
              ),
            ),
            // Baize felt center
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const RadialGradient(
                    center: Alignment(0, -0.2),
                    radius: 1.2,
                    colors: [kBaizeLight, kBaize, kBaizeEdge],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            // Felt texture overlay (subtle noise effect)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.3),
                    radius: 0.8,
                    colors: [
                      Colors.white.withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gold stud trim dots along the rail ──

class _StudTrimPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kGold.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final radius = 1.5;
    final spacing = 18.0;

    // Top edge
    for (double x = spacing; x < size.width - spacing; x += spacing) {
      canvas.drawCircle(Offset(x, 2), radius, paint);
    }
    // Bottom edge
    for (double x = spacing; x < size.width - spacing; x += spacing) {
      canvas.drawCircle(Offset(x, size.height - 2), radius, paint);
    }
    // Left edge
    for (double y = spacing; y < size.height - spacing; y += spacing) {
      canvas.drawCircle(Offset(2, y), radius, paint);
    }
    // Right edge
    for (double y = spacing; y < size.height - spacing; y += spacing) {
      canvas.drawCircle(Offset(size.width - 2, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Phase indicator: 5-dot progress bar ──

class PhaseIndicator extends StatelessWidget {
  final int currentPhase; // 0=preflop, 1=flop, 2=turn, 3=river, 4=showdown
  final List<String> labels;

  const PhaseIndicator({
    super.key,
    required this.currentPhase,
    this.labels = const ['Pre', 'Flop', 'Turn', 'River', 'Show'],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(labels.length, (i) {
        final isActive = i <= currentPhase;
        final isCurrent = i == currentPhase;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (i > 0)
              Container(
                width: 16,
                height: 1.5,
                color: isActive ? kPhaseActive.withValues(alpha: 0.5) : kPhaseLine,
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 10 : 7,
                  height: isCurrent ? 10 : 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? kPhaseActive : kPhaseInactive,
                    border: isCurrent
                        ? Border.all(color: kGold.withValues(alpha: 0.5), width: 2)
                        : null,
                    boxShadow: isCurrent
                        ? [BoxShadow(color: kGold.withValues(alpha: 0.3), blurRadius: 6)]
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? kGold : kTextSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
