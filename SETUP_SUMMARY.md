# Machiavelliam — Setup Summary

## Stack

| Layer | Technology |
|-------|-----------|
| Mobile app | Flutter (Dart), cross-platform: iOS / Android / Web |
| API | Vercel serverless functions (TypeScript, Node 20) |
| Database | Neon serverless Postgres |
| AI | OpenAI GPT-4.1-mini |
| Package manager (local) | Homebrew (macOS) |

---

## Environment Setup

### Flutter
```bash
brew install --cask flutter
flutter doctor
```

### Node (for Vercel functions)
```bash
brew install node   # Node 20+ required
```

### Dependencies
```bash
# Flutter
flutter pub get

# Vercel functions
npm install
```

---

## Neon Database

1. Create a project at neon.tech
2. Run `db/migrations/001_initial_schema.sql` in the Neon SQL editor
3. Copy the connection string — this becomes `DATABASE_URL`

Schema: `sessions`, `hands`, `player_actions`

---

## Vercel Deployment

1. Connect the GitHub repo to a new Vercel project
2. Set root directory to `machiavelliam_mobile`
3. Select **no framework preset** — `vercel.json` handles build config
4. Add environment variables in the Vercel dashboard:
   - `DATABASE_URL` — Neon connection string
   - `OPENAI_API_KEY` — OpenAI key

Vercel auto-deploys on push to `main`. Preview deployments created on `dev` branch.

---

## Local Development

No local API server needed for mobile development. Run Flutter against the deployed Vercel URL:

```bash
flutter run --dart-define=API_BASE_URL=https://machiavelliam.vercel.app
```

For local API iteration (optional):
```bash
npx vercel dev   # requires linking to existing Vercel project
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

---

## iOS Build Setup

CocoaPods required for iOS:
```bash
brew install cocoapods
```

Release build (requires Apple Developer account + code signing):
```bash
flutter build ios --release
```

For simulator testing (no signing required):
```bash
flutter run -d "iPhone 16 Pro"
```

---

## Key Files

| File | Purpose |
|------|---------|
| `vercel.json` | Vercel build config (Flutter web + API routes) |
| `package.json` | Node deps for Vercel functions |
| `.env.local` | Local secrets (gitignored) |
| `.env.example` | Template for required env vars |
| `lib/services/api_client.dart` | API base URL constant |
| `lib/services/session_service.dart` | Session/hand/action persistence |
| `lib/services/insights_service.dart` | AI coaching API call |
| `api/insights.ts` | OpenAI coaching prompt |
| `db/migrations/001_initial_schema.sql` | Neon schema |

---

*Last updated: 2026-03-08*
