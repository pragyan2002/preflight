# preflight adapters

An adapter is a POSIX sh file that implements five functions:

| Function | Arguments | Returns |
|---|---|---|
| `adapter_install_plugin` | `<plugin-id>` `<scope>` | exit 0 on success, 1 on failure |
| `adapter_list_plugins` | (none) | newline-separated `name@marketplace` strings |
| `adapter_add_marketplace` | `<name>` `<repo>` | exit 0 on success, 1 on failure |
| `adapter_list_marketplaces` | (none) | newline-separated marketplace names |
| `adapter_is_installed` | `<plugin-id>` | prints `1` if installed, `0` if not |

`adapter_is_installed` is the critical one for correctness. It must handle
whatever internal representation the tool uses (JSON file, database, API).
The Claude adapter reads `installed_plugins.json` directly and matches by
prefix to handle scope suffixes (`#project`, `#user`, `#local`).

## Adapter detection

Checked in this order:

1. `PREFLIGHT_ADAPTER` env var — explicit override, highest priority
2. `claude` binary in PATH → `adapters/claude.sh`
3. *(stubs for codex, cursor, windsurf — not yet implemented)*

## Adding a new adapter

1. Create `adapters/<toolname>.sh`
2. Implement all five functions
3. Add detection logic to `bin/preflight` in `detect_adapter()`
4. Add a row to this README's table
5. Open a PR

## Current adapters

| File | Tool | Status |
|---|---|---|
| `claude.sh` | Claude Code | v1.0.0 |
| `codex.sh` | OpenAI Codex | Planned |
| `cursor.sh` | Cursor | Planned |
| `windsurf.sh` | Windsurf | Planned |

## Note on `core/detect-missing.sh`

The hook (`scripts/check-deps.sh`) cannot source adapters — it fires before
the user's shell environment is set up. For the hook, `core/detect-missing.sh`
reads `installed_plugins.json` directly as a hardcoded fallback for Claude Code.
The CLI always goes through `adapter_is_installed`. This is an intentional
design decision documented in `core/detect-missing.sh`.
