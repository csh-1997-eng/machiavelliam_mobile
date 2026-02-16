#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# init_project.sh
# Fills placeholders in AI_RULES.md / CLAUDE.md / AGENTS.md (and optionally others)
# -----------------------------

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

require_file() {
  if [[ ! -f "$1" ]]; then
    echo "ERROR: Expected file '$1' not found. Run this from a repo that contains it."
    exit 1
  fi
}

# Check required files (adjust if your template differs)
require_file "AI_RULES.md"
require_file "CLAUDE.md"
require_file "AGENTS.md"

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

  # shellcheck disable=SC2163
  eval "$var_name=\"\$input\""
}

# Helper: safe "in-place" replace across macOS/Linux using perl
replace_in_file() {
  local file="$1"
  local needle="$2"
  local replacement="$3"

  # Escape backslashes and dollar signs for perl replacement
  local safe_repl
  safe_repl="$(printf '%s' "$replacement" | sed -e 's/\\/\\\\/g' -e 's/\$/\\\$/g')"

  perl -0777 -pe "s/\Q$needle\E/$safe_repl/g" -i "$file"
}

# Which files to apply replacements to
TARGET_FILES=(
  "AI_RULES.md"
  "CLAUDE.md"
  "AGENTS.md"
)

# Optional: also fill placeholders in Cursor rule files if you use them
if [[ -d ".cursor/rules" ]]; then
  while IFS= read -r -d '' f; do
    TARGET_FILES+=("${f#./}")
  done < <(find .cursor/rules -type f -name "*.mdc" -print0)
fi

# ---- Prompts (the "5 questions" + a couple optional) ----
prompt PROJECT_NAME "Project name" "$(basename "$ROOT_DIR")"
prompt STACK "Stack (e.g., python | ts | python+ts | infra)" ""

echo
echo "Enter commands. You can leave blank to fill later."
prompt FORMAT_CMD "Format command" ""
prompt LINT_CMD "Lint command" ""
prompt TYPECHECK_CMD "Typecheck command" ""
prompt TEST_CMD "Test command" ""
prompt BUILD_CMD "Build command" ""

# Fill blanks with a friendly placeholder to avoid leaving raw {{...}} around
fill_blank() {
  local v="$1"
  if [[ -z "$v" ]]; then
    echo "N/A (fill later)"
  else
    echo "$v"
  fi
}

FORMAT_CMD="$(fill_blank "$FORMAT_CMD")"
LINT_CMD="$(fill_blank "$LINT_CMD")"
TYPECHECK_CMD="$(fill_blank "$TYPECHECK_CMD")"
TEST_CMD="$(fill_blank "$TEST_CMD")"
BUILD_CMD="$(fill_blank "$BUILD_CMD")"

# ---- Apply replacements ----
echo
echo "Updating placeholders in:"
printf ' - %s\n' "${TARGET_FILES[@]}"
echo

for file in "${TARGET_FILES[@]}"; do
  [[ -f "$file" ]] || continue

  replace_in_file "$file" "{{PROJECT_NAME}}" "$PROJECT_NAME"
  replace_in_file "$file" "{{STACK}}" "$STACK"

  replace_in_file "$file" "{{FORMAT_CMD}}" "$FORMAT_CMD"
  replace_in_file "$file" "{{LINT_CMD}}" "$LINT_CMD"
  replace_in_file "$file" "{{TYPECHECK_CMD}}" "$TYPECHECK_CMD"
  replace_in_file "$file" "{{TEST_CMD}}" "$TEST_CMD"
  replace_in_file "$file" "{{BUILD_CMD}}" "$BUILD_CMD"
done

echo "Done."
echo
echo "Next steps:"
echo "  1) Review AI_RULES.md and tweak anything repo-specific"
echo "  2) Commit:"
echo "       git status"
echo "       git add -A"
echo "       git commit -m \"Initialize repo AI rules\""