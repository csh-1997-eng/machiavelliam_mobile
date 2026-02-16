# AI Rules Template

Personal AI coding assistant framework for maintaining consistency and quality across projects.

---

## What This Is

A private template repo that syncs AI configuration files (coding style, workflow patterns, specialized skills) to every project. AI tools (Cursor, Claude Code, Copilot) read these rules and generate code that matches my style.

**Goal:** AI-generated code should be indistinguishable from code I'd write myself.

---

## Template Structure

```
ai-rules-template/ (PRIVATE)
├── .custom-ruleset-manager/
│   ├── README.md                      # System documentation (public)
│   ├── init_project.sh               # One-time initialization (public)
│   └── sync_ai_ruleset.sh            # Sync latest rules (public)
├── rules/
│   ├── BASE_RULES.md                 # Core rules, voice, workflow (PRIVATE)
│   ├── PROJECT_SPECIFIC.template.md  # Template for overrides (becomes PROJECT_SPECIFIC.md)
│   └── skills/
│       ├── security_audit.md         # (PRIVATE)
│       ├── prototyping.md            # (PRIVATE)
│       ├── ui_design.md              # (PRIVATE)
│       ├── database_design.md        # (PRIVATE)
│       ├── testing.md                # (PRIVATE)
│       └── production.md             # (PRIVATE)
├── .cursor/rules/
│   └── 00-cursor-entrypoint.mdc      # Cursor config (PRIVATE)
├── AI_RULES.md                       # Project config template (public)
├── CLAUDE.md                         # Claude Code entrypoint (PRIVATE)
├── AGENTS.md                         # Codex entrypoint (PRIVATE)
├── LICENSE                           # MIT License (public)
└── .gitignore
```

---

## How It Works

**AI tools read files in this order:**
1. `AI_RULES.md` → Project commands and pointers
2. `rules/BASE_RULES.md` → Core coding philosophy (synced from template, gitignored)
3. `rules/PROJECT_SPECIFIC.md` → Project-specific overrides (committed, public)
4. `rules/skills/` → Specialized workflows loaded as needed (synced from template, gitignored)

**Public vs Private:**
- **Public (committed to project repos):** `AI_RULES.md`, `PROJECT_SPECIFIC.md`, `.custom-ruleset-manager/`
- **Private (gitignored, synced from template):** `BASE_RULES.md`, `skills/`, `CLAUDE.md`, `AGENTS.md`, `.cursor/rules/`

---

## Setup New Project

### 1. Create from Template

```bash
gh repo create my-project --template csh-1997-eng/ai-rules-template --private --clone
cd my-project
```

---

### 2. Add `.gitignore`

```gitignore
# AI Rules - PRIVATE (gitignored, synced from template)
/rules/BASE_RULES.md
/rules/skills/
/.cursor/rules/
/CLAUDE.md
/AGENTS.md

# AI Rules - PUBLIC (committed)
# /rules/PROJECT_SPECIFIC.md
# /AI_RULES.md
# /.custom-ruleset-manager/

# Project-specific (adjust per stack)
node_modules/
.env
*.pyc
__pycache__/
.venv/
.DS_Store
dist/
build/
.next/
```

```bash
git add .gitignore
git commit -m "Add gitignore"
```

---

### 3. Initialize Project

```bash
chmod +x .custom-ruleset-manager/*.sh
./.custom-ruleset-manager/init_project.sh
```

**Prompts for:**
- Project name
- Stack
- Commands (test, lint, build, etc.)

**Creates:**
- `AI_RULES.md` (filled in)
- `rules/PROJECT_SPECIFIC.md` (empty template)

**Deletes itself after success.**

---

### 4. Sync Rules from Template

```bash
chmod +x .custom-ruleset-manager/*.sh
./.custom-ruleset-manager/sync_ai_ruleset.sh
```

**Syncs from private template:**
- `rules/BASE_RULES.md`
- `rules/skills/`
- `.cursor/rules/`
- `CLAUDE.md`
- `AGENTS.md`
- `.custom-ruleset-manager/` files

**Never touches:**
- `AI_RULES.md`
- `rules/PROJECT_SPECIFIC.md`

---

### 5. Commit Public Files

```bash
git add AI_RULES.md rules/PROJECT_SPECIFIC.md .custom-ruleset-manager/
git commit -m "Initialize AI rules"
git push
```

---

## Usage Examples

### Example 1: Next.js Web App (Vercel)

**Project:** SaaS dashboard with Supabase backend

**Setup:**
```bash
gh repo create saas-dashboard --template ai-rules-template --private --clone
cd saas-dashboard
# Add .gitignore (include node_modules/, .env, .next/)
git add .gitignore && git commit -m "Add gitignore"

./.custom-ruleset-manager/init_project.sh
# Project name: SaaS Dashboard
# Stack: Next.js + Supabase + Vercel
# Test: pnpm test
# Build: pnpm build
# Lint: pnpm lint

./.custom-ruleset-manager/sync_ai_ruleset.sh

git add AI_RULES.md rules/PROJECT_SPECIFIC.md .custom-ruleset-manager/
git commit -m "Initialize AI rules"
git push
```

**Workflow:**
- AI follows BASE_RULES.md (Apple aesthetic UI, strong typing, dependency injection)
- Use `ui_design.md` skill for styling components
- Use `database_design.md` skill for Supabase schema
- Before deploy: AI loads `security_audit.md` and `production.md` skills

**PROJECT_SPECIFIC.md override example:**
```markdown
## UI/UX (BASE_RULES Section I):
- Client wants brand colors (blue #0066CC) - override minimalist gray
```

---

### Example 2: ML Pipeline (Experiments)

**Project:** Price prediction model with feature engineering

**Setup:**
```bash
gh repo create price-prediction --template ai-rules-template --private --clone
cd price-prediction
# Add .gitignore (include .venv/, *.pyc, __pycache__/, data/)
git add .gitignore && git commit -m "Add gitignore"

./.custom-ruleset-manager/init_project.sh
# Project name: Price Prediction
# Stack: Python + Pandas + scikit-learn
# Test: pytest -q
# Lint: ruff check .
# Format: ruff format .

./.custom-ruleset-manager/sync_ai_ruleset.sh

git add AI_RULES.md rules/PROJECT_SPECIFIC.md .custom-ruleset-manager/
git commit -m "Initialize AI rules"
git push
```

**Workflow:**
- AI follows BASE_RULES.md (concise code, strong typing with Pydantic)
- Use `prototyping.md` skill during experimentation (skip tests, move fast)
- No `production.md` needed yet (just experiments)

**PROJECT_SPECIFIC.md override example:**
```markdown
## Workflow (BASE_RULES Section J):
- This is research - prioritize speed over production readiness
- Log all model metrics (accuracy, F1, confusion matrix)

## Skills:
- Always use prototyping.md - exploratory work only
```

---

### Example 3: Mobile App Prototype

**Project:** React Native fitness tracker

**Setup:**
```bash
gh repo create fitness-tracker --template ai-rules-template --private --clone
cd fitness-tracker
# Add .gitignore (include node_modules/, .expo/, ios/Pods/)
git add .gitignore && git commit -m "Add gitignore"

./.custom-ruleset-manager/init_project.sh
# Project name: Fitness Tracker
# Stack: React Native + Expo
# Test: (leave empty - prototype)
# Build: expo build:ios
# Lint: (leave empty)

./.custom-ruleset-manager/sync_ai_ruleset.sh

git add AI_RULES.md rules/PROJECT_SPECIFIC.md .custom-ruleset-manager/
git commit -m "Initialize AI rules"
git push
```

**Workflow:**
- AI follows BASE_RULES.md (clean component structure, minimal abstraction)
- Use `prototyping.md` skill (skip tests, move fast)
- Use `ui_design.md` skill (minimalist design, touch targets 44x44px)

**PROJECT_SPECIFIC.md override example:**
```markdown
## Code Style (BASE_RULES Section C):
- Use Expo's conventions for file structure (app/, components/, hooks/)

## Skills:
- Always use prototyping.md - this is a quick POC
- Use ui_design.md for all screens (mobile-first, touch targets)
```

---

## Update Rules Across Projects

**Edit template:**
```bash
cd ai-rules-template
nano rules/BASE_RULES.md
git commit -m "Update error handling guidelines"
git push
```

**Sync to projects:**
```bash
cd ~/projects/saas-dashboard
./.custom-ruleset-manager/sync_ai_ruleset.sh  # Gets latest BASE_RULES.md

cd ~/projects/price-prediction
./.custom-ruleset-manager/sync_ai_ruleset.sh  # Gets latest BASE_RULES.md
```

---

## File Breakdown

**AI_RULES.md** - Project config (name, stack, commands). Points to BASE_RULES and PROJECT_SPECIFIC.

**BASE_RULES.md** - Core coding philosophy, voice samples, workflow patterns. Your IP.

**PROJECT_SPECIFIC.md** - Overrides BASE_RULES for this specific project. Public.

**skills/** - Specialized workflows:
- `security_audit.md` - Pre-deployment security checklist
- `prototyping.md` - Fast iteration mode (skip tests)
- `ui_design.md` - Apple aesthetic, responsive design
- `database_design.md` - Supabase/Postgres patterns
- `testing.md` - TDD, fixtures for expensive APIs
- `production.md` - Monitoring, cost protection

**CLAUDE.md / AGENTS.md / .cursor/rules/** - Entrypoints for AI tools.

---

## License

MIT License - see LICENSE file.