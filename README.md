# Machiavelliam Mobile

An AI poker coach for Texas Hold'em. Practice hands, record your decisions, and receive Machiavellian-level coaching — ranges, position pressure, exploitative play, and meta-game critique.

## Architecture

```
Flutter app (iOS/Android/Web)
  └── HTTP → Vercel API routes (TypeScript, Node 20)
                ├── /api/sessions   — create game sessions
                ├── /api/hands      — create/update hands
                ├── /api/actions    — record player decisions
                └── /api/insights   — AI coaching via OpenAI
                        └── Neon Postgres (serverless)
```

## Prerequisites

- Flutter SDK 3.9.2+
- Node.js 20+ (for Vercel functions locally)
- A deployed Vercel project with `DATABASE_URL` and `OPENAI_API_KEY` set

## Local Development

```bash
# Install Flutter deps
flutter pub get

# Run against deployed Vercel backend
flutter run --dart-define=API_BASE_URL=https://your-project.vercel.app

# Run on specific device
flutter run -d "iPhone 16 Pro" --dart-define=API_BASE_URL=https://your-project.vercel.app
```

## Project Structure

```
lib/
├── main.dart
├── controllers/
│   └── poker_game_controller.dart   # game state machine, session/hand tracking
├── models/
│   ├── card.dart
│   ├── deck.dart
│   ├── game_settings.dart
│   ├── player_action.dart           # ActionType enum + PlayerAction
│   └── poker_hand.dart
├── screens/
│   ├── game_screen.dart             # gameplay UI + action panel
│   ├── settings_screen.dart
│   └── home_screen.dart
└── services/
    ├── api_client.dart              # API base URL constant
    ├── insights_service.dart        # /api/insights call
    └── session_service.dart         # /api/sessions, /api/hands, /api/actions

api/
├── sessions.ts
├── hands.ts
├── actions.ts
└── insights.ts

db/
└── migrations/
    └── 001_initial_schema.sql
```

## Environment Variables

Copy `.env.example` to `.env.local` and fill in values (for `vercel dev` only):

```
DATABASE_URL=postgresql://...
OPENAI_API_KEY=sk-...
```

In production, set these in the Vercel dashboard.

## Build

```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release

# Web (deployed automatically by Vercel)
flutter build web --release --dart-define=API_BASE_URL=https://your-project.vercel.app
```

## Database

Run `db/migrations/001_initial_schema.sql` in your Neon project's SQL editor to initialize the schema.

## License

MIT License — Copyright (c) 2026 Cole Hoffman
