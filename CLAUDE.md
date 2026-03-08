# Claude Code Configuration

**Start Here:** Read `AI_RULES.md` first for project configuration and workflow policies.

**AI_RULES.md will direct you to:**
- `rules/BASE_RULES.md` - Core coding principles, voice, and style
- `rules/PROJECT_SPECIFIC.md` - Project-specific overrides and context

**Specialized Skills:** Available in `rules/skills/` directory. Load relevant skills based on task context:
- `security_audit.md` - Security reviews, vulnerability scanning
- `prototyping.md` - Fast iteration, proof-of-concept builds
- `ui_design.md` - Interface design and styling
- `database_design.md` - Schema design, migrations, queries
- `testing.md` - Test strategy and implementation
- `production.md` - Deployment, monitoring, alerts

**Skill Selection:** If your task involves security, read `security_audit.md`. If prototyping, read `prototyping.md`. If uncertain which skill applies, start with BASE_RULES.md only and ask for clarification.

**Reading Order:**
1. `AI_RULES.md` (project config, policies)
2. `rules/BASE_RULES.md` (core principles)
3. `rules/PROJECT_SPECIFIC.md` (project overrides)
4. `rules/skills/[relevant-skill].md` (if needed for task)