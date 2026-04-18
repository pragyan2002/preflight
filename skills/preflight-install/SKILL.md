---
name: preflight-install
description: Install all missing plugins declared in this project's preflight.json. Use when the user runs /preflight:install, when the session-start hook reports missing plugin dependencies, or when a team member has just cloned a repo and needs to set up their Claude Code environment. Registers missing marketplaces first, installs required plugins at project scope, then prompts for recommended plugins.
---

# Install plugin dependencies

Install all missing plugins declared in `preflight.json`.

**Note:** If you have the `preflight` CLI installed on your PATH, you can also run `preflight install` (or `preflight install --yes` for CI / non-interactive use) from the terminal.

## Steps

1. Check `$CLAUDE_PROJECT_DIR/preflight.json` exists. If not: suggest `/preflight:init`. Stop.
2. Validate manifest — `.preflight.required` and `.preflight.recommended` must be arrays.
3. Run `claude plugin marketplace list`. For each `.marketplaces` entry not registered:
   `claude plugin marketplace add {owner}/{repo}`
4. Run `claude plugin list --json`. For each `.preflight.required` plugin not installed:
   `claude plugin install {plugin} --scope project`
   Record failures — do not abort on a single failure.
5. For each `.preflight.recommended` plugin not installed: ask "Install `{name}`? (yes/no)".
6. Report summary: marketplaces registered, required N/N, recommended N, failures with error text.
7. If any required plugin failed: list each failure explicitly.
