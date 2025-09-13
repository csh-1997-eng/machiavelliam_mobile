enum Position {
  smallBlind,
  bigBlind,
  early,
  middle,
  late,
  button
}

class GameSettings {
  final int numberOfPlayers;
  final Position userPosition;
  final double buyIn;
  final double smallBlind;
  final double bigBlind;
  final int numberOfDecks;

  const GameSettings({
    required this.numberOfPlayers,
    required this.userPosition,
    required this.buyIn,
    required this.smallBlind,
    required this.bigBlind,
    required this.numberOfDecks,
  });

  GameSettings copyWith({
    int? numberOfPlayers,
    Position? userPosition,
    double? buyIn,
    double? smallBlind,
    double? bigBlind,
    int? numberOfDecks,
  }) {
    return GameSettings(
      numberOfPlayers: numberOfPlayers ?? this.numberOfPlayers,
      userPosition: userPosition ?? this.userPosition,
      buyIn: buyIn ?? this.buyIn,
      smallBlind: smallBlind ?? this.smallBlind,
      bigBlind: bigBlind ?? this.bigBlind,
      numberOfDecks: numberOfDecks ?? this.numberOfDecks,
    );
  }

  // Get all positions available for the given number of players
  static List<Position> getAvailablePositions(int playerCount) {
    List<Position> positions = [];
    
    if (playerCount >= 2) {
      positions.addAll([Position.smallBlind, Position.bigBlind]);
    }
    
    if (playerCount >= 3) {
      positions.add(Position.button);
    }
    
    if (playerCount >= 4) {
      positions.add(Position.early);
    }
    
    if (playerCount >= 6) {
      positions.add(Position.middle);
    }
    
    if (playerCount >= 8) {
      positions.add(Position.late);
    }
    
    return positions;
  }

  // Get position name for display
  static String getPositionName(Position position) {
    switch (position) {
      case Position.smallBlind:
        return 'Small Blind';
      case Position.bigBlind:
        return 'Big Blind';
      case Position.early:
        return 'Early Position';
      case Position.middle:
        return 'Middle Position';
      case Position.late:
        return 'Late Position';
      case Position.button:
        return 'Button';
    }
  }

  // Get position description
  static String getPositionDescription(Position position) {
    switch (position) {
      case Position.smallBlind:
        return 'First to act pre-flop, pays small blind';
      case Position.bigBlind:
        return 'Last to act pre-flop, pays big blind';
      case Position.early:
        return 'Acts early in betting rounds, play tighter';
      case Position.middle:
        return 'Acts in middle of betting rounds';
      case Position.late:
        return 'Acts late in betting rounds, can play more hands';
      case Position.button:
        return 'Last to act in most betting rounds, best position';
    }
  }

  @override
  String toString() {
    return 'GameSettings(players: $numberOfPlayers, position: ${getPositionName(userPosition)}, buyIn: \$${buyIn.toStringAsFixed(2)}, blinds: \$${smallBlind.toStringAsFixed(2)}/\$${bigBlind.toStringAsFixed(2)}, decks: $numberOfDecks)';
  }
}
