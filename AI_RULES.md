# AI RULES — Project: machiavelliam_mobile
Stack: {{STACK}}

This file contains project-specific configurations and commands.

**For general coding rules and principles, see:** `rules/BASE_RULES.md`
**For project-specific overrides and context, see:** `rules/PROJECT_SPECIFIC.md`
**For specialized workflows, see:** `rules/skills/`

**NEVER UPDATE THE AI_RULES.MD, PROJECT_SPECIFIC.MD, OR ANY OF THE RULES FILES WITHOUT EXPRESS PERMISSION**

---

## Project Configuration

**Project Name:** machiavelliam_mobile
**Stack:** {{STACK}}

---

## Repo-Specific Commands

### Format
dart format .

### Lint
flutter analyze

### Typecheck
flutter analyze

### Tests
flutter test

### Build
iOS: flutter build ios --release
Android: flutter build apk --release
Web: flutter build web --release

---

## About This File

This file defines project-specific commands and configurations for AI coding assistants.

The full ruleset (coding style, workflow patterns, security guidelines) is managed via a private template system and synced locally. These files are not committed to public repositories to protect proprietary development workflows.

For more information about the AI ruleset system, see `.custom-ruleset-manager/README.md`