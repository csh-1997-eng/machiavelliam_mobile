/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Widget: playing_card.dart
 * Purpose: Casino-style playing card with parchment face, ink suits,
 *          card back pattern, and 3D flip animation.
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/card.dart';
import '../theme/palazzo_colors.dart';

const double kCardWidth = 60;
const double kCardHeight = 84;

class PlayingCardWidget extends StatefulWidget {
  final PokerCard? card;
  final bool faceUp;
  final double scale;
  final bool animateFlip;
  final Duration flipDuration;
  final VoidCallback? onTap;

  const PlayingCardWidget({
    super.key,
    this.card,
    this.faceUp = true,
    this.scale = 1.0,
    this.animateFlip = true,
    this.flipDuration = const Duration(milliseconds: 400),
    this.onTap,
  });

  @override
  State<PlayingCardWidget> createState() => _PlayingCardWidgetState();
}

class _PlayingCardWidgetState extends State<PlayingCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _showFront = widget.faceUp;
    _controller = AnimationController(
      duration: widget.flipDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _animation.addListener(() {
      if (_animation.value >= math.pi / 2 && _showFront != widget.faceUp) {
        setState(() => _showFront = widget.faceUp);
      } else if (_animation.value < math.pi / 2 && _showFront == widget.faceUp && _controller.status == AnimationStatus.reverse) {
        setState(() => _showFront = !widget.faceUp);
      }
    });
  }

  @override
  void didUpdateWidget(PlayingCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.faceUp != widget.faceUp && widget.animateFlip) {
      if (widget.faceUp) {
        _showFront = false;
        _controller.forward(from: 0).then((_) {
          if (mounted) setState(() => _showFront = true);
        });
      } else {
        _showFront = true;
        _controller.forward(from: 0).then((_) {
          if (mounted) setState(() => _showFront = false);
        });
      }
    } else if (oldWidget.faceUp != widget.faceUp) {
      setState(() => _showFront = widget.faceUp);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = kCardWidth * widget.scale;
    final h = kCardHeight * widget.scale;

    if (!widget.animateFlip || _controller.status == AnimationStatus.dismissed) {
      return GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: w,
          height: h,
          child: _showFront && widget.card != null
              ? _CardFace(card: widget.card!, scale: widget.scale)
              : _CardBack(scale: widget.scale),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value;
          final isBack = angle >= math.pi / 2;
          final displayAngle = isBack ? math.pi - angle : angle;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(displayAngle),
            child: SizedBox(
              width: w,
              height: h,
              child: isBack == _showFront
                  ? (widget.card != null
                      ? _CardFace(card: widget.card!, scale: widget.scale)
                      : _CardBack(scale: widget.scale))
                  : _CardBack(scale: widget.scale),
            ),
          );
        },
      ),
    );
  }
}

// ── Card Face (parchment + ink) ──

class _CardFace extends StatelessWidget {
  final PokerCard card;
  final double scale;

  const _CardFace({required this.card, required this.scale});

  @override
  Widget build(BuildContext context) {
    final isRed = card.suit == Suit.hearts || card.suit == Suit.diamonds;
    final color = isRed ? kBloodRed : kInk;
    final rankStr = _rankLabel(card.rank);
    final suitStr = _suitSymbol(card.suit);
    final fontSize = 11.0 * scale;
    final suitSize = 22.0 * scale;
    final cornerPad = 3.0 * scale;

    return Container(
      decoration: BoxDecoration(
        color: kParchment,
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(color: kParchmentDark, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: kCardShadow,
            blurRadius: 4 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top-left rank + suit
          Positioned(
            left: cornerPad,
            top: cornerPad,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(rankStr, style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.0,
                )),
                Text(suitStr, style: TextStyle(
                  fontSize: fontSize * 0.9,
                  color: color,
                  height: 1.0,
                )),
              ],
            ),
          ),
          // Center suit (large)
          Center(
            child: Text(suitStr, style: TextStyle(
              fontSize: suitSize,
              color: color,
            )),
          ),
          // Bottom-right rank + suit (inverted)
          Positioned(
            right: cornerPad,
            bottom: cornerPad,
            child: Transform.rotate(
              angle: math.pi,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(rankStr, style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.0,
                  )),
                  Text(suitStr, style: TextStyle(
                    fontSize: fontSize * 0.9,
                    color: color,
                    height: 1.0,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card Back (diamond lattice pattern) ──

class _CardBack extends StatelessWidget {
  final double scale;
  const _CardBack({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBack,
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(color: kCardBackLight, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: kCardShadow,
            blurRadius: 4 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6 * scale),
        child: CustomPaint(
          painter: _CardBackPainter(scale: scale),
        ),
      ),
    );
  }
}

class _CardBackPainter extends CustomPainter {
  final double scale;
  _CardBackPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final borderInset = 4.0 * scale;
    final rect = Rect.fromLTWH(
      borderInset, borderInset,
      size.width - borderInset * 2, size.height - borderInset * 2,
    );

    // Inner border
    final borderPaint = Paint()
      ..color = kCardBackPattern.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 * scale;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(3 * scale)),
      borderPaint,
    );

    // Diamond lattice
    final linePaint = Paint()
      ..color = kCardBackPattern.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 * scale;

    final spacing = 8.0 * scale;
    for (double x = rect.left; x < rect.right; x += spacing) {
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x + rect.height * 0.5, rect.bottom),
        linePaint,
      );
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x - rect.height * 0.5, rect.bottom),
        linePaint,
      );
    }
    for (double x = rect.right; x > rect.left; x -= spacing) {
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x + rect.height * 0.5, rect.bottom),
        linePaint,
      );
    }

    // Center emblem (small diamond)
    final cx = size.width / 2;
    final cy = size.height / 2;
    final emblemSize = 8.0 * scale;
    final emblemPaint = Paint()
      ..color = kCardBackPattern.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(cx, cy - emblemSize)
      ..lineTo(cx + emblemSize * 0.7, cy)
      ..lineTo(cx, cy + emblemSize)
      ..lineTo(cx - emblemSize * 0.7, cy)
      ..close();
    canvas.drawPath(path, emblemPaint);
  }

  @override
  bool shouldRepaint(covariant _CardBackPainter old) => old.scale != scale;
}

// ── Slide-in animation wrapper ──

class CardDealAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideFrom;

  const CardDealAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 300),
    this.slideFrom = const Offset(1.5, -1.0),
  });

  @override
  State<CardDealAnimation> createState() => _CardDealAnimationState();
}

class _CardDealAnimationState extends State<CardDealAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: widget.slideFrom,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5)),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

// ── Helpers ──

String _rankLabel(Rank rank) {
  switch (rank) {
    case Rank.two: return '2';
    case Rank.three: return '3';
    case Rank.four: return '4';
    case Rank.five: return '5';
    case Rank.six: return '6';
    case Rank.seven: return '7';
    case Rank.eight: return '8';
    case Rank.nine: return '9';
    case Rank.ten: return '10';
    case Rank.jack: return 'J';
    case Rank.queen: return 'Q';
    case Rank.king: return 'K';
    case Rank.ace: return 'A';
  }
}

String _suitSymbol(Suit suit) {
  switch (suit) {
    case Suit.hearts: return '\u2665';
    case Suit.diamonds: return '\u2666';
    case Suit.clubs: return '\u2663';
    case Suit.spades: return '\u2660';
  }
}
