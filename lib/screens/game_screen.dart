/*
 * Copyright (c) 2026 Cole Hoffman
 * Licensed under MIT License - see LICENSE file for details
 *
 * Screen: game_screen.dart
 * Purpose: Palazzo game table — Renaissance private room aesthetic with
 *          felt table, card animations, chip stacks, and coaching panel.
 */

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../models/player_action.dart';
import '../models/opponent_profile.dart';
import '../controllers/poker_game_controller.dart';
import '../services/insights_service.dart';
import '../services/profile_service.dart';
import '../services/prompt_library.dart';
import '../theme/palazzo_colors.dart';
import '../utils/table_seating.dart';
import '../widgets/playing_card.dart';
import '../widgets/poker_chip.dart';
import '../widgets/felt_table.dart';
import '../widgets/glossary_tip.dart';
import 'profile_screen.dart';
import 'debrief_screen.dart';

class GameScreen extends StatefulWidget {
  final GameSettings settings;

  const GameScreen({
    super.key,
    required this.settings,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late PokerGameController _gameController;
  bool _dealingHand = false;
  bool _loadingInsights = false;
  bool _insightsReceivedForPhase = false;
  String? _insightsText;
  String? _profileSummary;
  String _coachingMode = 'balanced';
  final TextEditingController _questionController = TextEditingController();

  // Animation keys — increment to trigger new deal animations
  int _heroCardKey = 0;
  int _communityCardKey = 0;
  bool _showdownTriggered = false;

  @override
  void initState() {
    super.initState();
    _gameController = PokerGameController();
    _gameController.initializeGame(widget.settings);
    _initOpponents();
    _loadProfile();
  }

  void _initOpponents() {
    final seats = TableSeating.seatLabels(
      widget.settings.numberOfPlayers,
      widget.settings.userPosition,
    );
    final opponents = seats
        .map((seat) => OpponentProfile(seatLabel: seat, stack: widget.settings.buyIn))
        .toList();
    _gameController.setOpponents(opponents);
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile();
    if (mounted && profile?.summary != null) {
      setState(() => _profileSummary = profile!.summary);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  int get _phaseIndex {
    switch (_gameController.currentPhase) {
      case GamePhase.preflop: return 0;
      case GamePhase.flop: return 1;
      case GamePhase.turn: return 2;
      case GamePhase.river: return 3;
      case GamePhase.showdown: return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kWalnut,
        elevation: 0,
        title: PhaseIndicator(currentPhase: _phaseIndex),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: kGold),
            tooltip: 'Your Profile',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: _gameController.gameStarted && !_gameController.handComplete ? 100 : 16,
            ),
            child: Column(
              children: [
                _buildTable(),
                const SizedBox(height: 12),
                _buildHeroCards(),
                const SizedBox(height: 8),
                _buildHandStrength(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildActionButtons(),
                ),
                if (_gameController.gameStarted) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCoachingPanel(),
                  ),
                ],
              ],
            ),
          ),
          if (_gameController.gameStarted && !_gameController.handComplete)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildActionBar(),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLE
  // ══════════════════════════════════════════════════════

  Widget _buildTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: FeltTable(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOpponentArc(),
            const SizedBox(height: 12),
            _buildCommunityCards(),
            const SizedBox(height: 8),
            _buildPotDisplay(),
            const SizedBox(height: 4),
            _buildTableInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildOpponentArc() {
    final opponents = _gameController.opponents;
    if (opponents.isEmpty) return const SizedBox(height: 40);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final count = opponents.length;

        return SizedBox(
          height: 90,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(count, (i) {
              final angle = math.pi * (i + 1) / (count + 1);
              final x = totalWidth / 2 + (totalWidth * 0.42) * math.cos(angle) - 30;
              final y = 50 - 45 * math.sin(angle);

              return Positioned(
                left: x.clamp(0, totalWidth - 60),
                top: y.clamp(0, 60),
                child: _buildOpponentSeat(opponents[i]),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildOpponentSeat(OpponentProfile opp) {
    final isActive = opp.isActive;
    final isShowdown = _gameController.currentPhase == GamePhase.showdown;

    return GestureDetector(
      onTap: () {
        if (!isActive) return;
        setState(() {
          final keys = kArchetypeOrder;
          final currentIdx = keys.indexOf(opp.archetype.apiKey);
          final nextKey = keys[(currentIdx + 1) % keys.length];
          opp.archetype = PlayerArchetype.values.firstWhere((a) => a.apiKey == nextKey);
        });
      },
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 250),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PlayingCardWidget(
                  faceUp: isShowdown && _showdownTriggered,
                  scale: 0.5,
                  animateFlip: _showdownTriggered,
                ),
                const SizedBox(width: 2),
                PlayingCardWidget(
                  faceUp: isShowdown && _showdownTriggered,
                  scale: 0.5,
                  animateFlip: _showdownTriggered,
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              opp.seatLabel,
              style: const TextStyle(
                fontSize: 8,
                color: kParchment,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: kWalnut.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                opp.archetype.label,
                style: TextStyle(
                  fontSize: 7,
                  color: isActive ? kGold : kTextSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (opp.lastAction != null)
              Text(
                opp.lastAction!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  color: kGold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCards() {
    final cards = _gameController.communityCards;

    if (cards.isEmpty && !_gameController.gameStarted) {
      return SizedBox(
        height: kCardHeight * 0.75,
        child: Center(
          child: Text(
            'Deal to begin',
            style: TextStyle(
              fontSize: 13,
              color: kParchment.withValues(alpha: 0.4),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    if (cards.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: PlayingCardWidget(faceUp: false, scale: 0.75, animateFlip: false),
          );
        }),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(cards.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: CardDealAnimation(
            key: ValueKey('community_${_communityCardKey}_$i'),
            delay: Duration(milliseconds: 150 * i),
            slideFrom: const Offset(-1.5, 0),
            child: PlayingCardWidget(
              card: cards[i],
              faceUp: true,
              scale: 0.75,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPotDisplay() {
    if (!_gameController.gameStarted) return const SizedBox.shrink();

    return ChipStack(
      amount: _gameController.pot,
      label: 'Pot: \$${_gameController.pot.toStringAsFixed(0)}',
    );
  }

  Widget _buildTableInfo() {
    final showStack = _gameController.gameStarted;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _tableInfoLabel(
          GameSettings.getPositionName(_gameController.settings.userPosition),
          'POSITION',
        ),
        _tableInfoLabel(
          '\$${_gameController.settings.smallBlind.toStringAsFixed(0)}/\$${_gameController.settings.bigBlind.toStringAsFixed(0)}',
          'BLINDS',
        ),
        if (showStack) ...[
          _tableInfoLabel('\$${_gameController.heroStack.toStringAsFixed(0)}', 'STACK'),
          _tableInfoLabel(_gameController.spr.toStringAsFixed(1), 'SPR'),
        ],
      ],
    );
  }

  Widget _tableInfoLabel(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kParchment),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: kParchment.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  // HERO CARDS
  // ══════════════════════════════════════════════════════

  Widget _buildHeroCards() {
    final cards = _gameController.userHoleCards;
    if (cards.isEmpty) return const SizedBox(height: 20);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(cards.length, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: CardDealAnimation(
            key: ValueKey('hero_${_heroCardKey}_$i'),
            delay: Duration(milliseconds: 200 + 300 * i),
            slideFrom: const Offset(1.5, -1.0),
            child: PlayingCardWidget(
              card: cards[i],
              faceUp: true,
              scale: 1.3,
              animateFlip: true,
            ),
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════
  // HAND STRENGTH BADGE
  // ══════════════════════════════════════════════════════

  Widget _buildHandStrength() {
    final hand = _gameController.getCurrentHandEvaluation();
    final strength = _gameController.getHandStrength();

    if (hand == null && _gameController.userHoleCards.isEmpty) {
      return const SizedBox.shrink();
    }

    if (hand == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
          ),
          child: const Center(
            child: Text(
              'Awaiting community cards',
              style: TextStyle(fontSize: 12, color: kTextSecondary),
            ),
          ),
        ),
      );
    }

    final isFinal = _gameController.handComplete && _gameController.finalHand != null;
    final displayHand = isFinal ? _gameController.finalHand! : hand;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayHand.handName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kTextPrimary),
                ),
                const SizedBox(width: 8),
                Text(
                  '${strength.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kGold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: strength / 100,
                minHeight: 4,
                backgroundColor: kBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(kGold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // ACTION BAR — fixed bottom casino buttons
  // ══════════════════════════════════════════════════════

  Widget _buildActionBar() {
    final currentAction = _gameController.currentPhaseAction;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
      decoration: const BoxDecoration(
        color: kWalnut,
        border: Border(top: BorderSide(color: kWalnutLight, width: 1)),
        boxShadow: [
          BoxShadow(color: Color(0x60000000), blurRadius: 12, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentAction != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${currentAction.actionName.toUpperCase()}'
                  '${currentAction.amount != null ? '  \$${currentAction.amount!.toStringAsFixed(0)}' : ''}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kGold),
                ),
              ),
            Row(
              children: [
                _actionButton('FOLD', ActionType.fold, currentAction, kBloodRed),
                const SizedBox(width: 8),
                _actionButton('CHECK', ActionType.check, currentAction, null),
                const SizedBox(width: 8),
                _actionButton('CALL', ActionType.call, currentAction, null),
                const SizedBox(width: 8),
                _actionButton('BET', ActionType.bet, currentAction, kFeltGreen, isBet: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    String label,
    ActionType action,
    PlayerAction? currentAction,
    Color? accentColor, {
    bool isBet = false,
  }) {
    final isSelected = currentAction?.action == action;

    return Expanded(
      child: GestureDetector(
        onTap: () => isBet ? _showBetDialog() : _recordAction(action),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? kGold
                : accentColor?.withValues(alpha: 0.3) ?? kSurface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? kGold : kWalnutLight,
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? kWalnut : kTextPrimary,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // DEAL / ADVANCE / NEW HAND / END SESSION
  // ══════════════════════════════════════════════════════

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            if (!_gameController.gameStarted)
              Expanded(
                child: _palazzoButton(
                  label: 'Deal Hand',
                  onPressed: !_dealingHand ? _dealHand : null,
                  isLoading: _dealingHand,
                  isPrimary: true,
                ),
              ),
            if (_gameController.gameStarted && !_gameController.handComplete)
              Expanded(
                child: _palazzoButton(
                  label: _getNextPhaseButtonText(),
                  onPressed: _gameController.canProceedToNextPhase() ? _advancePhase : null,
                  isPrimary: true,
                ),
              ),
          ],
        ),
        if (_gameController.gameStarted) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _palazzoButton(
                  label: 'New Hand',
                  onPressed: !_dealingHand ? _dealHand : null,
                  isLoading: _dealingHand,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _palazzoButton(
                  label: 'End Session',
                  onPressed: () {
                    final sessionId = _gameController.sessionId;
                    if (sessionId == null) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DebriefScreen(sessionId: sessionId)),
                    );
                  },
                  accentColor: kCrimson,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _palazzoButton({
    required String label,
    VoidCallback? onPressed,
    bool isPrimary = false,
    bool isLoading = false,
    Color? accentColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: onPressed == null
              ? kSurface.withValues(alpha: 0.3)
              : isPrimary
                  ? kGold.withValues(alpha: 0.15)
                  : accentColor?.withValues(alpha: 0.2) ?? kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onPressed == null
                ? kBorder.withValues(alpha: 0.3)
                : isPrimary
                    ? kGold.withValues(alpha: 0.5)
                    : accentColor?.withValues(alpha: 0.4) ?? kBorder,
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(color: kGold, strokeWidth: 2),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: onPressed == null
                        ? kTextSecondary.withValues(alpha: 0.4)
                        : isPrimary ? kGold : kTextPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // COACHING PANEL — inline expandable card
  // ══════════════════════════════════════════════════════

  Widget _buildCoachingPanel() {
    final canGetCoaching = !_loadingInsights && !_insightsReceivedForPhase;

    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology, color: kGold, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'AI Coach',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kTextPrimary),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: canGetCoaching ? () => _fetchInsights() : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: canGetCoaching ? kGold.withValues(alpha: 0.15) : kSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: canGetCoaching ? kGold.withValues(alpha: 0.5) : kBorder,
                      ),
                    ),
                    child: _loadingInsights
                        ? const SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(color: kGold, strokeWidth: 2),
                          )
                        : Text(
                            'Get Coaching',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: canGetCoaching ? kGold : kTextSecondary,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Mode toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final mode in ['balanced', 'exploit'])
                  GestureDetector(
                    onTap: () => setState(() => _coachingMode = mode),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: _coachingMode == mode ? kGold : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _coachingMode == mode ? kGold : kBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            mode == 'balanced' ? 'GTO' : 'Exploit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _coachingMode == mode ? kWalnut : kTextSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GlossaryTip(
                            term: mode == 'balanced' ? 'GTO' : 'Exploit',
                            size: 11,
                            color: _coachingMode == mode ? kWalnut.withValues(alpha: 0.6) : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                const Text(
                  'MODE',
                  style: TextStyle(fontSize: 9, color: kTextSecondary, letterSpacing: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Question input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    style: const TextStyle(fontSize: 13, color: kTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ask the coach...',
                      hintStyle: TextStyle(color: kTextSecondary.withValues(alpha: 0.5), fontSize: 13),
                      isDense: true,
                      filled: true,
                      fillColor: kBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: kGold, width: 0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (q) {
                      if (q.trim().isNotEmpty) {
                        _fetchInsights(question: q.trim());
                        _questionController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _loadingInsights
                      ? null
                      : () {
                          final q = _questionController.text.trim();
                          if (q.isNotEmpty) {
                            _fetchInsights(question: q);
                            _questionController.clear();
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.send, color: kGold, size: 18),
                  ),
                ),
              ],
            ),
          ),
          if (_insightsText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Text(
                _insightsText!,
                style: const TextStyle(fontSize: 13, color: kTextPrimary, height: 1.5),
              ),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // STATE ACTIONS
  // ══════════════════════════════════════════════════════

  void _recordAction(ActionType action, {double? amount}) {
    setState(() {
      _gameController.recordAction(action, amount: amount);
    });
  }

  void _showBetDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Bet Amount', style: TextStyle(color: kTextPrimary)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: kTextPrimary),
          decoration: InputDecoration(
            prefixText: '\$',
            prefixStyle: const TextStyle(color: kGold),
            hintText: '0',
            hintStyle: TextStyle(color: kTextSecondary.withValues(alpha: 0.5)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kGold)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: kTextSecondary)),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              _recordAction(ActionType.bet, amount: amount);
              Navigator.pop(ctx);
            },
            child: const Text('Bet', style: TextStyle(color: kGold, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _dealHand() async {
    setState(() {
      _dealingHand = true;
      _insightsText = null;
      _insightsReceivedForPhase = false;
      _showdownTriggered = false;
      _heroCardKey++;
      _communityCardKey++;
    });
    await _gameController.startNewHand();
    if (mounted) setState(() => _dealingHand = false);
  }

  void _advancePhase() {
    final wasRiver = _gameController.currentPhase == GamePhase.river;
    setState(() {
      _gameController.advanceToNextPhase();
      _insightsReceivedForPhase = false;
      _insightsText = null;
      _communityCardKey++;
      if (wasRiver) _showdownTriggered = true;
    });
  }

  Future<void> _fetchInsights({String? question}) async {
    setState(() {
      _loadingInsights = true;
      _insightsText = null;
    });
    final opponents = _gameController.opponents;
    final result = await InsightsService.getInsights(
      userHoleCards: _gameController.userHoleCards,
      communityCards: _gameController.communityCards,
      currentEvaluation: _gameController.getCurrentHandEvaluation(),
      handStrengthPercent: _gameController.getHandStrength(),
      settings: _gameController.settings,
      phase: _gameController.currentPhase.name,
      playerAction: _gameController.currentPhaseAction,
      question: question,
      profileSummary: _profileSummary,
      coachingMode: _coachingMode,
      opponents: opponents.map((o) => o.toJson()).toList(),
      pot: _gameController.pot,
      heroStack: _gameController.heroStack,
      spr: _gameController.spr,
      previousResponseId: InsightsService.lastResponseId,
    );
    if (mounted) {
      setState(() {
        _insightsText = result ?? 'No coaching available.';
        _loadingInsights = false;
        if (question == null) _insightsReceivedForPhase = true;
      });
    }
  }

  String _getNextPhaseButtonText() {
    switch (_gameController.currentPhase) {
      case GamePhase.preflop: return 'Deal Flop';
      case GamePhase.flop: return 'Deal Turn';
      case GamePhase.turn: return 'Deal River';
      case GamePhase.river: return 'Showdown';
      case GamePhase.showdown: return 'Complete';
    }
  }
}
