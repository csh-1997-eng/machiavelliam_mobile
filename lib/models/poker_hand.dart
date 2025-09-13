import 'card.dart';

enum HandRank {
  highCard,
  pair,
  twoPair,
  threeOfAKind,
  straight,
  flush,
  fullHouse,
  fourOfAKind,
  straightFlush,
  royalFlush
}

class PokerHand {
  final List<PokerCard> cards;
  final HandRank rank;
  final List<PokerCard> bestCards;
  final List<int> kickers;

  const PokerHand({
    required this.cards,
    required this.rank,
    required this.bestCards,
    required this.kickers,
  });

  // Evaluate the best 5-card hand from 2 hole cards + 5 community cards
  static PokerHand evaluateHand(List<PokerCard> holeCards, List<PokerCard> communityCards) {
    if (holeCards.length != 2 || communityCards.length != 5) {
      throw ArgumentError('Need exactly 2 hole cards and 5 community cards');
    }

    List<PokerCard> allCards = [...holeCards, ...communityCards];
    
    // Try all combinations of 5 cards from the 7 available
    PokerHand bestHand = _evaluateFiveCards(allCards.sublist(0, 5));
    
    for (int i = 0; i < allCards.length - 4; i++) {
      for (int j = i + 1; j < allCards.length - 3; j++) {
        for (int k = j + 1; k < allCards.length - 2; k++) {
          for (int l = k + 1; l < allCards.length - 1; l++) {
            for (int m = l + 1; m < allCards.length; m++) {
              List<PokerCard> fiveCards = [allCards[i], allCards[j], allCards[k], allCards[l], allCards[m]];
              PokerHand hand = _evaluateFiveCards(fiveCards);
              if (_compareHands(hand, bestHand) > 0) {
                bestHand = hand;
              }
            }
          }
        }
      }
    }
    
    return PokerHand(
      cards: holeCards,
      rank: bestHand.rank,
      bestCards: bestHand.bestCards,
      kickers: bestHand.kickers,
    );
  }

  static PokerHand _evaluateFiveCards(List<PokerCard> cards) {
    if (cards.length != 5) {
      throw ArgumentError('Need exactly 5 cards');
    }

    // Sort cards by rank (descending)
    List<PokerCard> sortedCards = List.from(cards);
    sortedCards.sort((a, b) => b.value.compareTo(a.value));

    // Check for straight flush
    if (_isStraight(sortedCards) && _isFlush(sortedCards)) {
      if (sortedCards.first.rank == Rank.ace && sortedCards[1].rank == Rank.king) {
        return PokerHand(cards: cards, rank: HandRank.royalFlush, bestCards: sortedCards, kickers: []);
      }
      return PokerHand(cards: cards, rank: HandRank.straightFlush, bestCards: sortedCards, kickers: []);
    }

    // Check for four of a kind
    Map<int, int> rankCounts = _getRankCounts(sortedCards);
    for (int rank in rankCounts.keys) {
      if (rankCounts[rank] == 4) {
        List<PokerCard> fourOfAKind = sortedCards.where((c) => c.value == rank).toList();
        List<PokerCard> kicker = sortedCards.where((c) => c.value != rank).toList();
        return PokerHand(
          cards: cards,
          rank: HandRank.fourOfAKind,
          bestCards: [...fourOfAKind, kicker.first],
          kickers: [kicker.first.value],
        );
      }
    }

    // Check for full house
    bool hasThree = false;
    bool hasPair = false;
    int threeRank = 0;
    int pairRank = 0;
    
    for (int rank in rankCounts.keys) {
      if (rankCounts[rank] == 3 && !hasThree) {
        hasThree = true;
        threeRank = rank;
      } else if (rankCounts[rank] == 2 && !hasPair) {
        hasPair = true;
        pairRank = rank;
      }
    }

    if (hasThree && hasPair) {
        List<PokerCard> threeOfAKind = sortedCards.where((c) => c.value == threeRank).toList();
        List<PokerCard> pair = sortedCards.where((c) => c.value == pairRank).toList();
      return PokerHand(
        cards: cards,
        rank: HandRank.fullHouse,
        bestCards: [...threeOfAKind, ...pair],
        kickers: [threeRank, pairRank],
      );
    }

    // Check for flush
    if (_isFlush(sortedCards)) {
      return PokerHand(cards: cards, rank: HandRank.flush, bestCards: sortedCards, kickers: []);
    }

    // Check for straight
    if (_isStraight(sortedCards)) {
      return PokerHand(cards: cards, rank: HandRank.straight, bestCards: sortedCards, kickers: []);
    }

    // Check for three of a kind
    for (int rank in rankCounts.keys) {
      if (rankCounts[rank] == 3) {
        List<PokerCard> threeOfAKind = sortedCards.where((c) => c.value == rank).toList();
        List<PokerCard> kickers = sortedCards.where((c) => c.value != rank).toList();
        return PokerHand(
          cards: cards,
          rank: HandRank.threeOfAKind,
          bestCards: [...threeOfAKind, ...kickers.take(2)],
          kickers: kickers.take(2).map((c) => c.value).toList(),
        );
      }
    }

    // Check for two pair
    List<int> pairs = [];
    for (int rank in rankCounts.keys) {
      if (rankCounts[rank] == 2) {
        pairs.add(rank);
      }
    }

    if (pairs.length == 2) {
      pairs.sort((a, b) => b.compareTo(a));
      List<PokerCard> firstPair = sortedCards.where((c) => c.value == pairs[0]).toList();
      List<PokerCard> secondPair = sortedCards.where((c) => c.value == pairs[1]).toList();
      List<PokerCard> kicker = sortedCards.where((c) => c.value != pairs[0] && c.value != pairs[1]).toList();
      return PokerHand(
        cards: cards,
        rank: HandRank.twoPair,
        bestCards: [...firstPair, ...secondPair, kicker.first],
        kickers: [kicker.first.value],
      );
    }

    // Check for pair
    if (pairs.length == 1) {
      List<PokerCard> pair = sortedCards.where((c) => c.value == pairs[0]).toList();
      List<PokerCard> kickers = sortedCards.where((c) => c.value != pairs[0]).toList();
      return PokerHand(
        cards: cards,
        rank: HandRank.pair,
        bestCards: [...pair, ...kickers.take(3)],
        kickers: kickers.take(3).map((c) => c.value).toList(),
      );
    }

    // High card
    return PokerHand(
      cards: cards,
      rank: HandRank.highCard,
      bestCards: sortedCards,
      kickers: [],
    );
  }

  static bool _isFlush(List<PokerCard> cards) {
    Suit firstSuit = cards.first.suit;
    return cards.every((card) => card.suit == firstSuit);
  }

  static bool _isStraight(List<PokerCard> cards) {
    List<int> values = cards.map((c) => c.value).toList();
    values.sort();
    
    // Check for regular straight
    for (int i = 0; i < values.length - 1; i++) {
      if (values[i + 1] - values[i] != 1) {
        // Check for low ace straight (A-2-3-4-5)
        if (values.first == 2 && values.last == 14) {
          List<int> lowStraight = [2, 3, 4, 5, 14];
          return values.every((v) => lowStraight.contains(v));
        }
        return false;
      }
    }
    return true;
  }

  static Map<int, int> _getRankCounts(List<PokerCard> cards) {
    Map<int, int> counts = {};
    for (PokerCard card in cards) {
      counts[card.value] = (counts[card.value] ?? 0) + 1;
    }
    return counts;
  }

  static int _compareHands(PokerHand hand1, PokerHand hand2) {
    if (hand1.rank.index != hand2.rank.index) {
      return hand2.rank.index.compareTo(hand1.rank.index);
    }

    // Same rank, compare kickers
    for (int i = 0; i < hand1.kickers.length && i < hand2.kickers.length; i++) {
      if (hand1.kickers[i] != hand2.kickers[i]) {
        return hand1.kickers[i].compareTo(hand2.kickers[i]);
      }
    }

    return 0;
  }

  String get handName {
    switch (rank) {
      case HandRank.highCard:
        return 'High Card';
      case HandRank.pair:
        return 'Pair';
      case HandRank.twoPair:
        return 'Two Pair';
      case HandRank.threeOfAKind:
        return 'Three of a Kind';
      case HandRank.straight:
        return 'Straight';
      case HandRank.flush:
        return 'Flush';
      case HandRank.fullHouse:
        return 'Full House';
      case HandRank.fourOfAKind:
        return 'Four of a Kind';
      case HandRank.straightFlush:
        return 'Straight Flush';
      case HandRank.royalFlush:
        return 'Royal Flush';
    }
  }

  @override
  String toString() {
    return '$handName (${bestCards.map((c) => c.displayName).join(', ')})';
  }
}
