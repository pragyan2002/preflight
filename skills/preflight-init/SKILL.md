---
name: preflight-init
description: Scaffold a preflight.json manifest for this project from the user's currently installed plugins. Use when a team wants to start tracking plugin dependencies, when setting up a new project's Claude Code environment, or when a user asks how to share their plugin setup with teammates.
---

# Scaffold a plugin dependencies manifest

Create `preflight.json` by inspecting installed plugins and asking the user which to declare.

**Note:** If you have the `preflight` CLI installed, `preflight init` does the same thing from the terminal. Use `preflight init --yes` to mark all installed plugins as required non-interactively.

## Steps

1. Check if `$CLAUDE_PROJECT_DIR/preflight.json` already exists. Ask to overwrite if so.
2. Run `claude plugin list --json`.
3. Ask user to categorise each: required / recommended / skip.
4. For each unique marketplace (excluding `claude-plugins-official`), ask for GitHub repo if not registered.
5. Write manifest including `"versions": {}` and `"preflightVersion": "1"` (string, not number).
6. Run `/preflight:check` immediately after.
7. Show git commit commands.

Rules:
- `preflightVersion` must be `"1"` (string).
- Plugin identifiers must be `name@marketplace` format.
- Marketplace names in `.marketplaces` must match suffixes in plugin identifiers exactly.
- `claude-plugins-official` needs no `.marketplaces` entry — always pre-registered.
- Always include `"versions": {}` — reserved for v2 version constraints.
