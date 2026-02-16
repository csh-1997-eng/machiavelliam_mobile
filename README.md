# File Structure Explanation

Your template repo should contain:

```
/
├── AI_RULES.md                        # Project-specific rules + shell script params
├── CLAUDE.md                          # Claude Code entrypoint
├── AGENTS.md                          # Codex entrypoint
├── .cursor/
│   └── rules/
│       └── 00-cursor-entrypoint.mdc  # Cursor entrypoint
├── rules/
│   ├── BASE_RULES.md                 # Always-loaded core rules
│   └── skills/
│       ├── security_audit.md         # Security review workflows
│       ├── prototyping.md            # Fast iteration mode
│       ├── ui_design.md              # Interface & design guidelines
│       ├── database_design.md        # Schema & query patterns
│       ├── testing.md                # Test strategy
│       └── production.md             # Monitoring & deployment
```

---

## What Each File Does

### AI_RULES.md
Project-specific configuration and commands. Contains:
- Dependency policy (hard rule: don't modify without permission)
- Minimal diff policy (no unnecessary refactoring)
- Output format requirements (summary, files changed, commands to run)
- Repo-specific commands (format, lint, typecheck, test, build)

This file uses shell script placeholders (`{{PROJECT_NAME}}`, `{{STACK}}`, etc.) that get filled in by `init_project.sh`.

---

### CLAUDE.md
Claude Code entrypoint. Tells Claude Code to:
- Read `rules/BASE_RULES.md` for all tasks
- Load relevant skills from `rules/skills/` based on task context
- Follow project-specific rules in `AI_RULES.md`

---

### AGENTS.md
Codex entrypoint. Tells Codex to:
- Read `rules/BASE_RULES.md` first
- Load skills from `rules/skills/` as needed
- Follow project config in `AI_RULES.md`

---

### .cursor/rules/00-cursor-entrypoint.mdc
Cursor-specific entrypoint. Points Cursor to:
- `rules/BASE_RULES.md` for core rules
- `rules/skills/` for specialized workflows
- `AI_RULES.md` for project config

Cursor automatically injects `.mdc` files into its agent context.

---

### rules/BASE_RULES.md
**Always-loaded core rules.** Contains:
- Your identity, voice, and working style
- Aesthetic samples (for AI to match your writing)
- Core code style (typing, dependency injection, error handling)
- Security fundamentals (non-negotiable)
- Workflow (experiment → demo → deploy)
- How AI should handle uncertainty

This is the foundation. Every AI tool reads this first.

---

### rules/skills/
**Specialized workflows loaded on-demand:**

- **security_audit.md** - Deep security review, vulnerability scanning, pre-deployment checklist
- **prototyping.md** - Fast iteration mode (skip tests, optimize for speed)
- **ui_design.md** - Interface design, Apple aesthetic, responsive web design
- **database_design.md** - Schema design, migrations, query optimization (Supabase/Postgres)
- **testing.md** - Test strategy, TDD, integration tests, fixture usage
- **production.md** - Monitoring, alerts, cost protection, deployment checklist

AI tools only load skills relevant to the current task to save tokens and avoid confusion.

---

## How Skills Work

**Example 1:** You ask for a security review
- AI reads `BASE_RULES.md` (core principles)
- AI reads `security_audit.md` (deep security checklist)
- Result: Paranoid security review with vulnerability scanning

**Example 2:** You ask to build a quick demo
- AI reads `BASE_RULES.md` (core principles)
- AI reads `prototyping.md` (fast iteration mode)
- Result: Working demo in <1 hour, skips tests/optimization

**Example 3:** You ask to design a user dashboard
- AI reads `BASE_RULES.md` (core principles)
- AI reads `ui_design.md` (Apple aesthetic, responsive design)
- Result: Clean, minimalist interface that works on all devices

---

# Get Started Building (2-minute setup)

Open `AI_RULES.md` and replace the following placeholders:

- `{{PROJECT_NAME}}` - Your project name
- `{{STACK}}` - Your tech stack (e.g., "Next.js + Supabase", "FastAPI + Postgres")
- `{{FORMAT_CMD}}` - Command to format code (or leave empty if not using)
- `{{LINT_CMD}}` - Command to lint code (or leave empty if not using)
- `{{TYPECHECK_CMD}}` - Command to typecheck (or leave empty if not using)
- `{{TEST_CMD}}` - Command to run tests
- `{{BUILD_CMD}}` - Command to build project (or leave empty if not applicable)

**Note:** The extra command placeholders (FORMAT, LINT, TYPECHECK) are optional scaffolding for projects with specific tooling. If your project doesn't use formatters/linters/typecheckers, leave them empty or remove them. They exist for future flexibility as your project matures.

---

## Example: Python Repo

```markdown
{{PROJECT_NAME}} → ML Pipeline API
{{STACK}} → FastAPI + Postgres + OpenAI
{{FORMAT_CMD}} → ruff format .
{{LINT_CMD}} → ruff check .
{{TYPECHECK_CMD}} → mypy src/
{{TEST_CMD}} → pytest -q
{{BUILD_CMD}} → (leave empty - no build step)
```

---

## Example: Next.js Repo

```markdown
{{PROJECT_NAME}} → SaaS Dashboard
{{STACK}} → Next.js + Supabase + Vercel
{{FORMAT_CMD}} → pnpm format
{{LINT_CMD}} → pnpm lint
{{TYPECHECK_CMD}} → pnpm typecheck
{{TEST_CMD}} → pnpm test
{{BUILD_CMD}} → pnpm build
```

---

# Quick Tutorial: Setting Up AI Rules + Init Script (Mac + Cursor)

This setup is designed specifically for **Mac users using Cursor as the primary IDE**.

- The `init_project.sh` script is **macOS-focused** (also works on Linux)
- The `.cursor/rules/*` files are **Cursor-specific** - other IDEs won't auto-load them
- This makes **Claude Code + Codex + Cursor** behave consistently across every repo

---

## 1) Run the `init_project.sh` Script (Mac)

### Step A — Make it executable

From the repo root, run:

```bash
chmod +x scripts/init_project.sh
```

---

### Step B — Run it

```bash
./scripts/init_project.sh
```

It will ask you a few questions:
- Project name
- Stack
- Test / lint / format commands

Then it automatically fills in placeholders inside your rules files (like `{{TEST_CMD}}`).

---

## 2) Why Cursor Rule Files Start With Numbers

Cursor loads rule files in **alphabetical order**.

Naming them:
- `00-cursor-entrypoint.mdc`

ensures they load predictably. If you add more Cursor-specific rules later, you can use:
- `10-project-specific.mdc`
- `20-team-conventions.mdc`

This keeps things organized and controls rule priority.

---

## 3) Platform Notes

**This setup works across platforms:**
- Web apps (Next.js, React, Vue, etc.)
- APIs (FastAPI, Flask, Node.js, etc.)
- Data pipelines (Python, notebooks, ETL)
- ML projects (training, inference, experimentation)
- Desktop apps (Electron, Tauri, etc.)

**For mobile apps specifically:**
If you're building iOS/Android apps, you may want to add `rules/skills/mobile_development.md` for platform-specific patterns (React Native, Flutter, native iOS/Android). The current setup is platform-agnostic and works for any type of project.

---

## 4) How to Use Skills

**Invoke skills explicitly when needed:**

```
[Use prototyping skill] Build me a quick demo of a chatbot
```

```
[Apply security_audit skill] Review this authentication code
```

```
[Use ui_design skill] Create a dashboard for user analytics
```

Or let the AI infer from context:
- "Review this code for vulnerabilities" → AI loads `security_audit.md`
- "Build a quick proof of concept" → AI loads `prototyping.md`
- "Design the login page" → AI loads `ui_design.md`

---

## 5) Modifying Rules

**To update core principles:** Edit `rules/BASE_RULES.md`

**To add/modify skills:** Edit files in `rules/skills/`

**To change project config:** Edit `AI_RULES.md`

All AI tools (Claude Code, Codex, Cursor) will pick up changes automatically on next run.
