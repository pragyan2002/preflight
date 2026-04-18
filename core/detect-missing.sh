#!/bin/sh
# core/detect-missing.sh
#
# Shared detection logic for preflight.
# Sourced by scripts/check-deps.sh (hook) and bin/preflight (CLI).
# Never executed directly.
#
# INPUTS (must be set by caller):
#   MANIFEST         — absolute path to preflight.json
#   INSTALLED        — absolute path to installed_plugins.json (Claude fallback)
#
# OUTPUTS (set as variables for caller to use):
#   MISSING          — newline+dash formatted string of missing plugin names
#   MISSING_COUNT    — integer count of missing required plugins
#
# NOTE ON ADAPTER VS DIRECT READ:
#   The hook cannot source adapters — it fires before the user's shell
#   environment is available. The hook passes INSTALLED (the raw JSON file
#   path) and this function reads it directly.
#
#   The CLI sources an adapter first, then calls adapter_is_installed.
#   To support both, callers set USE_ADAPTER=1 to route through the adapter,
#   or leave it unset to use the direct file read (hook path).

MISSING=""
MISSING_COUNT=0
MAX_LISTED=10

# Validate: .preflight.required must exist and be an array.
# Returns 0 if valid, 1 if empty/missing (nothing to check), 2 if malformed.
validate_required_field() {
  REQ_TYPE=$(jq -r '(.preflight.required // "missing") | type' "$MANIFEST" 2>/dev/null)
  if [ "$REQ_TYPE" = "missing" ] || [ -z "$REQ_TYPE" ]; then
    return 1   # no required deps — nothing to check
  fi
  if [ "$REQ_TYPE" != "array" ]; then
    return 2   # malformed
  fi
  return 0
}

# Populate MISSING and MISSING_COUNT from .preflight.required.
collect_missing() {
  while IFS= read -r plugin; do
    [ -z "$plugin" ] && continue

    if [ "${USE_ADAPTER:-0}" = "1" ]; then
      # CLI path: delegate to adapter
      FOUND=$(adapter_is_installed "$plugin" 2>/dev/null || echo "0")
    else
      # Hook path: read JSON file directly
      FOUND=0
      if [ -f "$INSTALLED" ]; then
        FOUND=$(jq --arg p "$plugin" \
          '[keys[] | select(startswith($p + "#") or . == $p)] | length' \
          "$INSTALLED" 2>/dev/null)
        [ -z "$FOUND" ] && FOUND=0
      fi
    fi

    if [ "$FOUND" = "0" ]; then
      MISSING_COUNT=$((MISSING_COUNT + 1))
      if [ $MISSING_COUNT -le $MAX_LISTED ]; then
        MISSING="${MISSING}\\n  - ${plugin}"
      fi
    fi
  done << EOF
$(jq -r '.preflight.required[]' "$MANIFEST" 2>/dev/null)
EOF

  if [ $MISSING_COUNT -gt $MAX_LISTED ]; then
    OVERFLOW=$((MISSING_COUNT - MAX_LISTED))
    MISSING="${MISSING}\\n  ... and ${OVERFLOW} more"
  fi
}
