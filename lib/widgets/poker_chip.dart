/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Widget: poker_chip.dart
 * Purpose: Florentine-style poker chip with concentric rings,
 *          embossed amount label, and optional stacking.
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/palazzo_colors.dart';

enum ChipColor { gold, silver, burgundy, dark }

class PokerChipWidget extends StatelessWidget {
  final double amount;
  final ChipColor chipColor;
  final double size;
  final bool showAmount;

  const PokerChipWidget({
    super.key,
    required this.amount,
    this.chipColor = ChipColor.gold,
    this.size = 40,
    this.showAmount = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ChipPainter(
          chipColor: chipColor,
          size: size,
        ),
        child: showAmount
            ? Center(
                child: Text(
                  _formatAmount(amount),
                  style: TextStyle(
                    fontSize: size * 0.24,
                    fontWeight: FontWeight.w800,
                    color: _textColor,
                    height: 1.0,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Color get _textColor {
    switch (chipColor) {
      case ChipColor.gold: return kWalnut;
      case ChipColor.silver: return kInk;
      case ChipColor.burgundy: return kParchment;
      case ChipColor.dark: return kTextPrimary;
    }
  }

  static String _formatAmount(double amount) {
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}k';
    if (amount == amount.roundToDouble()) return amount.toInt().toString();
    return amount.toStringAsFixed(1);
  }
}

class _ChipPainter extends CustomPainter {
  final ChipColor chipColor;
  final double size;

  _ChipPainter({required this.chipColor, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = canvasSize.width / 2;

    final (mainColor, rimColor) = _colors;

    // Outer shadow
    canvas.drawCircle(
      center + Offset(0, size * 0.03),
      radius,
      Paint()..color = const Color(0x40000000),
    );

    // Outer rim
    canvas.drawCircle(center, radius, Paint()..color = rimColor);

    // Main face
    canvas.drawCircle(center, radius * 0.85, Paint()..color = mainColor);

    // Edge notches (8 notches around the rim)
    final notchPaint = Paint()
      ..color = kParchment.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.04
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 8;
      final inner = radius * 0.82;
      final outer = radius * 0.98;
      canvas.drawLine(
        Offset(center.dx + inner * math.cos(angle), center.dy + inner * math.sin(angle)),
        Offset(center.dx + outer * math.cos(angle), center.dy + outer * math.sin(angle)),
        notchPaint,
      );
    }

    // Inner ring
    canvas.drawCircle(
      center,
      radius * 0.55,
      Paint()
        ..color = rimColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.02,
    );
  }

  (Color, Color) get _colors {
    switch (chipColor) {
      case ChipColor.gold: return (kChipGold, kChipGoldRim);
      case ChipColor.silver: return (kChipSilver, kChipSilverRim);
      case ChipColor.burgundy: return (kChipBurgundy, kChipBurgundyRim);
      case ChipColor.dark: return (kChipDark, kChipDarkRim);
    }
  }

  @override
  bool shouldRepaint(covariant _ChipPainter old) =>
      old.chipColor != chipColor || old.size != size;
}

// ── Chip stack: pot display with stacked chips + label ──

class ChipStack extends StatelessWidget {
  final double amount;
  final String? label;

  const ChipStack({
    super.key,
    required this.amount,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = amount >= 100
        ? ChipColor.gold
        : amount >= 50
            ? ChipColor.silver
            : ChipColor.burgundy;
    final stackCount = (amount / 25).clamp(1, 4).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 36 + (stackCount - 1) * 3.0,
          width: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(stackCount, (i) {
              return Positioned(
                bottom: i * 3.0,
                left: 0,
                child: PokerChipWidget(
                  amount: amount,
                  chipColor: i == stackCount - 1 ? chipColor : ChipColor.dark,
                  size: 36,
                  showAmount: i == stackCount - 1,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label ?? '\$${PokerChipWidget._formatAmount(amount)}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: kGold,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
