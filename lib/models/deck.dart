import 'card.dart';

class Deck {
  List<PokerCard> _cards = [];
  int _currentIndex = 0;

  Deck() {
    _initializeDeck();
  }

  void _initializeDeck() {
    _cards = [];
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        _cards.add(PokerCard(suit, rank));
      }
    }
    _currentIndex = 0;
  }

  // Shuffle the deck
  void shuffle() {
    _cards.shuffle();
    _currentIndex = 0;
  }

  // Deal a single card
  PokerCard? dealCard() {
    if (_currentIndex >= _cards.length) {
      return null; // No more cards
    }
    return _cards[_currentIndex++];
  }

  // Deal multiple cards
  List<PokerCard> dealCards(int count) {
    List<PokerCard> dealtCards = [];
    for (int i = 0; i < count; i++) {
      PokerCard? card = dealCard();
      if (card != null) {
        dealtCards.add(card);
      } else {
        break; // No more cards available
      }
    }
    return dealtCards;
  }

  // Get remaining cards count
  int get remainingCards => _cards.length - _currentIndex;

  // Check if deck has enough cards
  bool hasEnoughCards(int count) => remainingCards >= count;

  // Reset deck (reshuffle and reset index)
  void reset() {
    _initializeDeck();
    shuffle();
  }

  // Get all cards (for testing purposes)
  List<PokerCard> get allCards => List.unmodifiable(_cards);

  // Create multiple decks (for games that use more than one deck)
  static Deck createMultipleDecks(int deckCount) {
    Deck deck = Deck();
    deck._cards = [];
    
    for (int deckNum = 0; deckNum < deckCount; deckNum++) {
      for (final suit in Suit.values) {
        for (final rank in Rank.values) {
          deck._cards.add(PokerCard(suit, rank));
        }
      }
    }
    
    deck._currentIndex = 0;
    deck.shuffle();
    return deck;
  }
}
