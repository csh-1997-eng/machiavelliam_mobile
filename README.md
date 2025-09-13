# 🃏 Macheiavelliam Mobile App

A Flutter application designed to help you learn poker strategies, develop better gameplay, and analyze your decision-making through realistic hand simulations.

## 🎯 Features

### Core Functionality
- **Realistic Hand Simulation**: Practice single poker hands with proper Texas Hold'em rules
- **Position-Based Strategy**: Learn how table position affects your play
- **Hand Strength Analysis**: Get real-time evaluation of your hand strength
- **Customizable Game Settings**: Configure players, blinds, buy-ins, and more

### Game Configuration
- **Player Count**: 2-10 players
- **Table Positions**: Small Blind, Big Blind, Early, Middle, Late, Button
- **Blind Structure**: Customizable small and big blind amounts
- **Buy-in Amounts**: Flexible buy-in settings
- **Multiple Decks**: Support for 1-8 decks

### Learning Tools
- **Hand Evaluation**: Complete poker hand ranking system
- **Strategy Advice**: Position-based recommendations
- **Visual Card Representation**: Color-coded cards with proper symbols
- **Progressive Betting Rounds**: Pre-flop → Flop → Turn → River → Showdown

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- iOS Simulator or Android Emulator (for mobile testing)
- Web browser (for web testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd macheiavelliam_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For web (recommended for testing)
   flutter run -d chrome
   
   # For iOS simulator
   flutter run -d "iPhone 16 Pro"
   
   # For Android emulator
   flutter run -d android
   ```

## 📱 How to Use

### 1. Main Screen
- View current game settings
- Navigate to settings or start a game

### 2. Game Settings
- **Number of Players**: Adjust from 2-10 players
- **Your Position**: Select your table position
- **Buy-in**: Set your starting stack amount
- **Blinds**: Configure small and big blind amounts
- **Decks**: Choose number of decks (1-8)

### 3. Game Simulation
- **Deal Hand**: Get your hole cards
- **Progressive Betting**: Deal flop, turn, river in sequence
- **Hand Analysis**: View real-time hand strength and advice
- **Position Tips**: Get strategic recommendations

## 🏗️ Project Structure

```
lib/
├── models/
│   ├── card.dart           # Playing card representation
│   ├── deck.dart           # Deck management and shuffling
│   ├── game_settings.dart  # Game configuration
│   └── poker_hand.dart     # Hand evaluation and ranking
├── controllers/
│   └── poker_game_controller.dart  # Game logic and state
├── screens/
│   ├── settings_screen.dart  # Game configuration UI
│   └── game_screen.dart      # Main game interface
└── main.dart               # App entry point
```

## 🧠 Poker Learning Features

### Hand Rankings
- High Card
- Pair
- Two Pair
- Three of a Kind
- Straight
- Flush
- Full House
- Four of a Kind
- Straight Flush
- Royal Flush

### Position Strategy
- **Early Position**: Play tighter, fewer hands
- **Middle Position**: Moderate hand selection
- **Late Position**: Can play more hands, steal blinds
- **Button**: Best position, last to act
- **Blinds**: Defend based on pot odds

## 🛠️ Development

### Building for Production

```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release

# Web
flutter build web --release
```

### Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📚 Learning Resources

This app helps you learn:
- **Poker Fundamentals**: Hand rankings, betting rounds, positions
- **Strategic Thinking**: When to fold, call, or raise
- **Position Play**: How table position affects decisions
- **Hand Evaluation**: Assessing hand strength in different situations

## 🎮 Game Flow

1. **Configure Settings**: Set up your preferred game parameters
2. **Deal Hole Cards**: Receive your two private cards
3. **Pre-flop Decision**: Evaluate your hand strength and position
4. **Community Cards**: Watch as flop, turn, and river are dealt
5. **Hand Analysis**: Get real-time feedback on your hand strength
6. **Learn and Improve**: Use position advice to make better decisions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🎯 Future Enhancements

- [ ] Multi-hand session tracking
- [ ] Advanced statistics and analysis
- [ ] Tournament simulation
- [ ] AI opponent integration
- [ ] Hand history playback
- [ ] Custom strategy profiles
- [ ] Bankroll management tools

## 🐛 Bug Reports

If you find a bug, please create an issue with:
- Description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if applicable)

## 📞 Support

For questions or support, please open an issue or contact the development team.

---

**Happy Learning!** 🃏♠️♥️♦️♣️