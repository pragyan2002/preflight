#!/bin/sh
# scripts/check-deps.sh — SessionStart hook for preflight
#
# Thin wrapper around core/detect-missing.sh.
# All detection logic lives in core/ — this file handles guards,
# sources core, and formats the JSON output for Claude Code.
#
# OUTPUT CONTRACT — never violated:
#   stdout = single JSON object OR completely empty. Nothing else.
#   stderr = always suppressed (2>/dev/null on every command)
#   exit   = always 0 (hook failures must not block a session)

MANIFEST="${CLAUDE_PROJECT_DIR:-$PWD}/preflight.json"
INSTALLED="${HOME}/.claude/installed_plugins.json"

# Hook always uses the direct file read path (not adapter).
# Adapters cannot be sourced here — hook fires before shell env is set up.
USE_ADAPTER=0

# Guard: no manifest
[ ! -f "$MANIFEST" ] && exit 0

# Guard: jq unavailable
command -v jq > /dev/null 2>&1 || exit 0

# Guard: invalid JSON
jq empty "$MANIFEST" > /dev/null 2>&1 || {
  jq -n '{"additionalContext": "preflight: preflight.json is not valid JSON. Run /preflight:check to diagnose."}' 2>/dev/null
  exit 0
}

# Source shared detection logic
# CLAUDE_PLUGIN_ROOT is set by Claude Code; falls back to relative path for tests
CORE_DIR="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)}/core"
. "${CORE_DIR}/detect-missing.sh" 2>/dev/null || exit 0

# Validate schema
validate_required_field
VALID_STATUS=$?
if [ $VALID_STATUS -eq 1 ]; then
  exit 0  # no required deps declared
fi
if [ $VALID_STATUS -eq 2 ]; then
  jq -n '{"additionalContext": "preflight: preflight.json is malformed — .preflight.required must be an array. Run /preflight:check for details."}' 2>/dev/null
  exit 0
fi

# Collect missing plugins
collect_missing

# Nothing missing — exit silently
[ "$MISSING_COUNT" = "0" ] && exit 0

# Emit additionalContext
MSG="preflight: This project has unsatisfied plugin dependencies.\\n\\nMissing required plugins (${MISSING_COUNT}):${MISSING}\\n\\nRun /preflight:install to resolve, or \`preflight install\` if you have the CLI on PATH.\\nRun /preflight:check for the full audit."

jq -n --arg ctx "$MSG" '{"additionalContext": $ctx}' 2>/dev/null
exit 0
