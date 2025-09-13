enum Suit { hearts, diamonds, clubs, spades }

enum Rank { 
  two, three, four, five, six, seven, eight, nine, ten, 
  jack, queen, king, ace 
}

class PokerCard {
  final Suit suit;
  final Rank rank;

  const PokerCard(this.suit, this.rank);

  @override
  String toString() {
    final rankStr = rank.toString().split('.').last;
    final suitStr = suit.toString().split('.').last;
    return '${rankStr.toUpperCase()}_${suitStr.toUpperCase()}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PokerCard && other.suit == suit && other.rank == rank;
  }

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;

  // Get the value of the card for hand evaluation
  int get value {
    switch (rank) {
      case Rank.two: return 2;
      case Rank.three: return 3;
      case Rank.four: return 4;
      case Rank.five: return 5;
      case Rank.six: return 6;
      case Rank.seven: return 7;
      case Rank.eight: return 8;
      case Rank.nine: return 9;
      case Rank.ten: return 10;
      case Rank.jack: return 11;
      case Rank.queen: return 12;
      case Rank.king: return 13;
      case Rank.ace: return 14;
    }
  }

  // Get the display name for UI
  String get displayName {
    final rankStr = rank.toString().split('.').last;
    final suitSymbol = _getSuitSymbol();
    return '$rankStr$suitSymbol';
  }

  String _getSuitSymbol() {
    switch (suit) {
      case Suit.hearts: return '♥';
      case Suit.diamonds: return '♦';
      case Suit.clubs: return '♣';
      case Suit.spades: return '♠';
    }
  }

  // Get the color of the card
  String get color {
    switch (suit) {
      case Suit.hearts:
      case Suit.diamonds:
        return 'red';
      case Suit.clubs:
      case Suit.spades:
        return 'black';
    }
  }
}
