#!/bin/bash
set -euo pipefail

# -----------------------------
# sync_ai_rules.sh
# Syncs AI rules from private template repo
# Requires SSH access to private template
# Safe to run multiple times
# -----------------------------

TEMPLATE_REPO="git@github.com:csh-1997-eng/ai-base-repo-template.git"  # ⚠️ UPDATE THIS
TEMP_DIR=$(mktemp -d)

# Cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

echo ""
echo "📥 Syncing AI Rules from Private Template"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Clone private template (requires SSH key)
echo "🔐 Cloning template repo (requires SSH access)..."
if ! git clone --depth 1 "$TEMPLATE_REPO" "$TEMP_DIR" 2>/dev/null; then
  echo ""
  echo "❌ ERROR: Could not clone template repo."
  echo ""
  echo "Possible reasons:"
  echo "  1. You don't have SSH access to the private template repo"
  echo "  2. SSH key not configured (run: ssh -T git@github.com)"
  echo "  3. Wrong repository URL (check TEMPLATE_REPO in this script)"
  echo ""
  exit 1
fi

echo "✅ Template cloned"
echo ""

# Create directories if they don't exist
mkdir -p rules/skills .cursor/rules scripts

# Sync files from template
echo "🔄 Syncing files..."

# 1. Sync BASE_RULES.md (always overwrite)
if [[ -f "$TEMP_DIR/rules/BASE_RULES.md" ]]; then
  cp "$TEMP_DIR/rules/BASE_RULES.md" "./rules/"
  echo "   ✓ rules/BASE_RULES.md"
fi

# 2. Sync skills (always overwrite)
if [[ -d "$TEMP_DIR/rules/skills" ]]; then
  rsync -a --delete "$TEMP_DIR/rules/skills/" "./rules/skills/"
  echo "   ✓ rules/skills/"
fi

# 3. Sync Cursor rules (always overwrite)
if [[ -d "$TEMP_DIR/.cursor/rules" ]]; then
  rsync -a --delete "$TEMP_DIR/.cursor/rules/" "./.cursor/rules/"
  echo "   ✓ .cursor/rules/"
fi

# 4. Sync entrypoint files (always overwrite)
if [[ -f "$TEMP_DIR/CLAUDE.md" ]]; then
  cp "$TEMP_DIR/CLAUDE.md" "./"
  echo "   ✓ CLAUDE.md"
fi

if [[ -f "$TEMP_DIR/AGENTS.md" ]]; then
  cp "$TEMP_DIR/AGENTS.md" "./"
  echo "   ✓ AGENTS.md"
fi

# 5. Sync this script itself (so it can be updated)
if [[ -f "$TEMP_DIR/scripts/sync_ai_rules.sh" ]]; then
  cp "$TEMP_DIR/scripts/sync_ai_rules.sh" "./scripts/"
  chmod +x ./scripts/sync_ai_rules.sh
  echo "   ✓ scripts/sync_ai_rules.sh"
fi

# 6. Create PROJECT_SPECIFIC.md if it doesn't exist (one-time only, never overwrite)
if [[ ! -f "./rules/PROJECT_SPECIFIC.md" ]]; then
  echo ""
  echo "📝 Creating PROJECT_SPECIFIC.md (one-time only)..."
  
  if [[ -f "$TEMP_DIR/rules/PROJECT_SPECIFIC.template.md" ]]; then
    cp "$TEMP_DIR/rules/PROJECT_SPECIFIC.template.md" "./rules/PROJECT_SPECIFIC.md"
  else
    cat > "./rules/PROJECT_SPECIFIC.md" << 'EOF'
# Project-Specific Rules

This file is local to this project and will never be overwritten by sync.

## Project Context
- **Name:** [Fill in]
- **Purpose:** [Fill in]
- **Special Requirements:** [Fill in]

## Project-Specific Overrides

Add any rules specific to this project that override or extend BASE_RULES.md.

### Example:
- This project uses a legacy API that requires XML instead of JSON
- All functions must include retry logic (infrastructure is flaky)
- Use verbose logging (client wants detailed logs)

EOF
  fi
  echo "   ✓ rules/PROJECT_SPECIFIC.md (created)"
fi

# 7. Create AI_RULES.md if it doesn't exist (one-time only, never overwrite)
if [[ ! -f "./AI_RULES.md" ]]; then
  echo ""
  echo "📝 Creating AI_RULES.md template..."
  echo "   ⚠️  You need to run ./scripts/init_project.sh to fill placeholders"
  
  if [[ -f "$TEMP_DIR/AI_RULES.md" ]]; then
    cp "$TEMP_DIR/AI_RULES.md" "./"
    echo "   ✓ AI_RULES.md (created with placeholders)"
  fi
fi

echo ""
echo "✅ Sync complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Summary:"
echo ""
echo "🔄 Synced (will be overwritten on next sync):"
echo "   • rules/BASE_RULES.md"
echo "   • rules/skills/"
echo "   • .cursor/rules/"
echo "   • CLAUDE.md"
echo "   • AGENTS.md"
echo "   • scripts/sync_ai_rules.sh"
echo ""
echo "🔒 Protected (never overwritten):"
echo "   • rules/PROJECT_SPECIFIC.md"
echo "   • AI_RULES.md"
echo ""
echo "💡 Tip: Run this script anytime to get latest rules from template"
echo ""