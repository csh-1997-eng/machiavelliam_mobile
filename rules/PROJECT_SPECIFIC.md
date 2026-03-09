# Project-Specific Rules

Overrides BASE_RULES.md when in conflict.

---

## Project Context
- **Name:** Machiavelliam Mobile
- **Purpose:** AI poker coach — Texas Hold'em simulator with Machiavellian-level strategic coaching via OpenAI. Ranges, equity, position pressure, meta-game, exploitative play. Not just math.
- **Stack Notes:**
  - Flutter (Dart) — iOS primary, Android secondary, web optional later
  - Vercel serverless API routes (TypeScript, Node 20) — API-only, no Flutter web build on Vercel
  - Neon serverless Postgres via `@neondatabase/serverless`
  - OpenAI GPT-4.1-mini for coaching (`/api/insights`)
  - No Supabase anywhere — fully removed

---

## Overrides by Section

**C) Code Style:**
- Dart: follow standard Flutter conventions, use `final` everywhere possible, no `var` unless type is obvious
- TypeScript API routes: all use `setCors(res)` helper pattern (individual `res.setHeader()` calls, not `.setHeaders()`)
- All API routes follow the same structure: setCors → OPTIONS check → method check → sql → try/catch

**E) Error Handling:**
- All Vercel API routes: wrap DB + OpenAI calls in try/catch, log with `[route-name]` prefix, return `{ error: 'Internal server error' }` on failure
- Flutter: fail gracefully on API errors — show user-facing message, never crash

**F) Dependency Injection:**
- `neon(process.env.DATABASE_URL!)` is initialized inside each handler (Neon serverless is stateless by design — this is correct, not a violation)
- Flutter services receive no global state — `ApiClient` injects the base URL via `--dart-define`

**H) Optimization:**
- Do not optimize hand evaluation or AI prompts unless specifically asked

**I) UI/UX:**
- Target feel: Bellagio table meets Bloomberg Terminal
- Dark, sophisticated palette — no Material green
- Typographic dominance, whitespace as containment, motion purposeful only
- Phase 6 (UI Overhaul) is a planned phase — do not proactively refactor UI unless working on Phase 6

**J) Workflow:**
- Local dev: `flutter run --dart-define=API_BASE_URL=https://machiavelliam.vercel.app`
- No local API server needed — always run Flutter against deployed Vercel URL
- Deploy flow: commit to `dev` → push → open PR to `main` → Vercel auto-deploys on merge
- Do NOT force-push `main` unless explicitly asked

**Skills:**
- Use `database_design.md` when touching Neon schema or SQL
- Use `security_audit.md` before any deploy
- Use `ui_design.md` when working on Phase 6

**Additional:**
- AI provider is locked to OpenAI GPT-4.1-mini — do not suggest migrating to Claude or any other provider
- Neon schema tables: `sessions`, `hands`, `player_actions` — see `db/migrations/001_initial_schema.sql`
- `sessions` table has a `buy_in` column (added after initial migration)
- `.gitignore` excludes: `CLAUDE.md`, `AGENTS.md`, `AI_RULES.md`, `rules/BASE_RULES.md`, `rules/skills/`, `node_modules/`, `.env.local`
- `.custom-ruleset-manager/` is intentionally tracked in git

---

## MVP Phase Tracker

| Phase | Status | Description |
|-------|--------|-------------|
| 1 | Done | DB schema + Vercel API layer |
| 2 | Done | Player action capture + persistence |
| 3 | In Progress | Upgraded AI coaching (prompt done; "Ask the Coach" + conversational tone pending) |
| 4 | Not Started | Style profiling (VPIP, PFR, aggression factor) |
| 5 | Not Started | Hypothetical / scenario mode |
| 6 | Not Started | UI overhaul (Bellagio x Bloomberg) |

---

**NOTE TO AI:** Ignore everything below this line. The following is documentation for humans only.

---

*Last updated: 2026-03-08*
