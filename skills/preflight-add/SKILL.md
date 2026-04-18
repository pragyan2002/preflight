---
name: preflight-add
description: Add an already-installed plugin to this project's preflight.json manifest without re-installing it. Use when the user has just installed a new plugin mid-project and wants to declare it as a team dependency. This is the answer to "I installed a new plugin — how do I add it to the manifest?" Equivalent to `preflight add <plugin>` if the CLI is installed.
---

# Add a plugin to the manifest

Add an already-installed plugin to `preflight.json` without re-installing it.

**Note:** If you have the `preflight` CLI installed, run `preflight add <plugin@marketplace>` or `preflight add <plugin> --recommended` from the terminal.

## Steps

1. Ask which plugin to add (`name@marketplace` format required).
2. Ask: required or recommended?
3. Check `$CLAUDE_PROJECT_DIR/preflight.json` exists — create it with empty lists if not.
4. Check if already in either list. If in wrong list, offer to move it.
5. Add using jq:
   ```sh
   jq --arg p "{plugin}" --arg c "{required|recommended}" \
     '.preflight[$c] += [$p]' preflight.json > tmp.json && mv tmp.json preflight.json
   ```
6. Show git commit instructions.

Does NOT install the plugin — only updates the manifest. Suggest `/preflight:install` if the user also needs to install.
