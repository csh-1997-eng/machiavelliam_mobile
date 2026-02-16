#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# init_project.sh
# 1. Fills placeholders in AI_RULES.md
# 2. Creates PROJECT_SPECIFIC.md from template
# 3. Deletes itself and the template after successful completion
# Run once after cloning template repo
# -----------------------------

# Get root directory (script is in .custom-ruleset-manager/ folder)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

require_file() {
  if [[ ! -f "$1" ]]; then
    echo "❌ ERROR: Expected file '$1' not found."
    exit 1
  fi
}

# Check required files
require_file "AI_RULES.md"
require_file "rules/PROJECT_SPECIFIC.template.md"

# Helper: read input with a default
prompt() {
  local var_name="$1"
  local message="$2"
  local default="${3:-}"
  local input

  if [[ -n "$default" ]]; then
    read -r -p "$message [$default]: " input
    input="${input:-$default}"
  else
    read -r -p "$message: " input
  fi

  eval "$var_name=\"\$input\""
}

# Helper: safe in-place replace using perl
replace_in_file() {
  local file="$1"
  local needle="$2"
  local replacement="$3"

  # Escape special characters for perl
  local safe_repl
  safe_repl="$(printf '%s' "$replacement" | sed -e 's/\\/\\\\/g' -e 's/\$/\\\$/g')"

  perl -0777 -pe "s/\Q$needle\E/$safe_repl/g" -i "$file"
}

# Fill blanks with placeholder
fill_blank() {
  local v="$1"
  if [[ -z "$v" ]]; then
    echo "N/A (fill later)"
  else
    echo "$v"
  fi
}

echo ""
echo "🎯 AI Rules Project Initialization"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Prompts
prompt PROJECT_NAME "Project name" "$(basename "$ROOT_DIR")"
prompt STACK "Stack (e.g., Next.js + Supabase, FastAPI + Postgres)" ""

echo ""
echo "📦 Optional: Repo-specific commands (leave blank to fill later)"
prompt FORMAT_CMD "Format command (e.g., ruff format .)" ""
prompt LINT_CMD "Lint command (e.g., ruff check .)" ""
prompt TYPECHECK_CMD "Typecheck command (e.g., mypy src/)" ""
prompt TEST_CMD "Test command (e.g., pytest -q)" ""
prompt BUILD_CMD "Build command (e.g., pnpm build)" ""

# Fill empty values with placeholder
FORMAT_CMD="$(fill_blank "$FORMAT_CMD")"
LINT_CMD="$(fill_blank "$LINT_CMD")"
TYPECHECK_CMD="$(fill_blank "$TYPECHECK_CMD")"
TEST_CMD="$(fill_blank "$TEST_CMD")"
BUILD_CMD="$(fill_blank "$BUILD_CMD")"

# Apply replacements to AI_RULES.md
echo ""
echo "📝 Updating AI_RULES.md..."

replace_in_file "AI_RULES.md" "{{PROJECT_NAME}}" "$PROJECT_NAME"
replace_in_file "AI_RULES.md" "{{STACK}}" "$STACK"
replace_in_file "AI_RULES.md" "{{FORMAT_CMD}}" "$FORMAT_CMD"
replace_in_file "AI_RULES.md" "{{LINT_CMD}}" "$LINT_CMD"
replace_in_file "AI_RULES.md" "{{TYPECHECK_CMD}}" "$TYPECHECK_CMD"
replace_in_file "AI_RULES.md" "{{TEST_CMD}}" "$TEST_CMD"
replace_in_file "AI_RULES.md" "{{BUILD_CMD}}" "$BUILD_CMD"

echo "✅ AI_RULES.md initialized successfully"
echo ""

# Create PROJECT_SPECIFIC.md from template
echo "📝 Creating PROJECT_SPECIFIC.md from template..."
cp "rules/PROJECT_SPECIFIC.template.md" "rules/PROJECT_SPECIFIC.md"
echo "✅ PROJECT_SPECIFIC.md created"
echo ""

# Delete template file (no longer needed)
echo "🗑️  Deleting PROJECT_SPECIFIC.template.md (no longer needed)..."
rm -f "rules/PROJECT_SPECIFIC.template.md"

# Delete this script (one-time use only)
SCRIPT_PATH="${BASH_SOURCE[0]}"
echo "🗑️  Deleting init_project.sh (one-time use only)..."
rm -f "$SCRIPT_PATH"

echo ""
echo "✅ Initialization complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Review AI_RULES.md and rules/PROJECT_SPECIFIC.md and adjust if needed"
echo "   2. Run sync script to pull latest rules:"
echo "      ./.custom-ruleset-manager/sync_ai_ruleset.sh"
echo "   3. Commit public files:"
echo "      git add AI_RULES.md rules/PROJECT_SPECIFIC.md .custom-ruleset-manager/"
echo "      git commit -m 'Initialize AI rules'"
echo ""