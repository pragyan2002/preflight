---
name: preflight-check
description: Audit this project's plugin dependencies and show their status without making any changes. Use when the user runs /preflight:check, wants to verify their environment matches the manifest, or needs to diagnose why a plugin seems to be missing. Read-only — installs nothing.
---

# Audit plugin dependencies

Read-only audit of `preflight.json` against the current environment.

**Note:** If you have the `preflight` CLI installed on your PATH, you can also run `preflight check` (exits 1 if any required deps are missing — CI-friendly).

## Steps

1. Check `$CLAUDE_PROJECT_DIR/preflight.json` exists. If not: suggest `/preflight:init`.
2. Run `claude plugin marketplace list` — check each `.marketplaces` entry.
3. Run `claude plugin list --json` — check each `.preflight.required` and `.preflight.recommended` plugin.
4. Print formatted output with ✓/✗ per item.
5. End with "All dependencies satisfied." or "N required plugins missing. Run /preflight:install."

Never installs, uninstalls, or modifies configuration.
