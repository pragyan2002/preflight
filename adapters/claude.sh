#!/bin/sh
# adapters/claude.sh — Claude Code adapter for preflight
#
# Implements the five-function adapter interface.
# Sourced by bin/preflight at runtime — never executed directly.
#
# Requires: claude CLI, jq

# Install a plugin by ID at the given scope.
adapter_install_plugin() {
  PLUGIN_ID="$1"
  SCOPE="${2:-project}"
  claude plugin install "$PLUGIN_ID" --scope "$SCOPE" > /dev/null 2>&1
}

# Return newline-separated list of installed plugin identifiers.
# Reads installed_plugins.json directly — faster than spawning claude.
# Strips scope suffixes so callers get clean name@marketplace strings.
adapter_list_plugins() {
  INSTALLED_FILE="${HOME}/.claude/installed_plugins.json"
  [ ! -f "$INSTALLED_FILE" ] && return 0
  jq -r 'keys[] | split("#")[0]' "$INSTALLED_FILE" 2>/dev/null | sort -u
}

# Look up a marketplace's source repo from Claude Code's known_marketplaces.json.
# Returns owner/repo for github-type sources, full URL for git-type sources.
# Prints nothing and returns 1 for directory-type or unknown marketplaces.
adapter_get_marketplace_repo() {
  MARKETPLACE="$1"
  KNOWN="${HOME}/.claude/plugins/known_marketplaces.json"
  [ ! -f "$KNOWN" ] && return 1
  jq -r --arg m "$MARKETPLACE" \
    '.[$m].source | if .source == "github" then .repo
                    elif .source == "git" then .url
                    else empty end' \
    "$KNOWN" 2>/dev/null
}

# Register a marketplace by name and GitHub repo.
adapter_add_marketplace() {
  MKT_NAME="$1"
  MKT_REPO="$2"
  claude plugin marketplace add "$MKT_REPO" > /dev/null 2>&1
}

# Return newline-separated list of registered marketplace names.
adapter_list_marketplaces() {
  claude plugin marketplace list 2>/dev/null | awk '{print $1}'
}

# Check whether a plugin is installed.
# Prints "1" if installed, "0" if not.
# Handles scope suffixes in installed_plugins.json keys:
#   "brand-voice@company-tools#project" → matches "brand-voice@company-tools"
adapter_is_installed() {
  PLUGIN_ID="$1"
  INSTALLED_FILE="${HOME}/.claude/installed_plugins.json"
  if [ ! -f "$INSTALLED_FILE" ]; then
    echo "0"
    return
  fi
  FOUND=$(jq --arg p "$PLUGIN_ID" \
    '[keys[] | select(startswith($p + "#") or . == $p)] | length' \
    "$INSTALLED_FILE" 2>/dev/null)
  [ -z "$FOUND" ] && FOUND=0
  echo "$FOUND"
}

# Verify the required binary is present.
adapter_verify() {
  command -v claude > /dev/null 2>&1 || {
    printf "preflight: Claude Code CLI (claude) not found in PATH.\n" >&2
    printf "Install from: https://code.claude.com\n" >&2
    return 1
  }
}
