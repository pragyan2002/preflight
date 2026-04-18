# preflight

**Your team clones the repo. Three plugins are missing. Nobody notices until something breaks.**

preflight fixes that. Declare your Claude Code plugins in `preflight.json`, commit it, and every teammate gets told exactly what to install — automatically, on their first session.

```sh
/plugin install preflight@claude-plugins-official
```

---

## The problem

You've been on the project for months. Your Claude Code setup is dialled in — brand voice plugin, deployment tools, security scanner, the works. Everything just works.

Then someone new joins. They clone the repo, open Claude Code, and start working. Except Claude doesn't know your brand voice. Doesn't have the deployment tools. The security scanner isn't there. Nobody mentioned this anywhere. The new person doesn't know what they're missing because they don't know what they *should* have.

Two hours later someone asks why their PR looks different.

This happens on every team that uses Claude Code plugins. There's been no fix — until now.

---

## Before / After

| Without preflight | With preflight |
|---|---|
| New dev clones repo | New dev clones repo |
| Opens Claude Code | Opens Claude Code |
| Everything seems fine | Claude says: *"This project needs brand-voice and deployment-tools. Run /preflight:install."* |
| Silently missing 3 plugins | Runs `/preflight:install` |
| Discovers the problem 2 hours later | 30 seconds. Done. Every plugin installed. |

**Same repo. 30 seconds vs 2 hours.**

---

## Install

```sh
/plugin install preflight@claude-plugins-official
```

Or directly from this repo:
```sh
/plugin marketplace add pragyan2002/preflight
/plugin install preflight@preflight
```

---

## How it works

**Step 1 — declare your plugins** (you do this once):

```sh
/preflight:init
```

Asks you which installed plugins are required for the project. Writes `preflight.json` to the repo root. Commit it.

**Step 2 — teammate clones the repo:**

On their first Claude Code session in the project, they see:

```
preflight: This project has unsatisfied plugin dependencies.

Missing required plugins (2):
  - brand-voice@company-tools
  - deployment-tools@company-tools

Run /preflight:install to resolve.
```

**Step 3:**

```
/preflight:install
```

Done. Every plugin installed. Every teammate synced.

---

## What preflight handles

| Situation | What happens |
|---|---|
| Teammate clones repo | Hook fires, missing plugins surfaced immediately |
| Plugin not installed | `/preflight:install` registers marketplace + installs |
| New plugin added mid-project | `preflight add brand-voice@company-tools` updates the manifest |
| CI pipeline | `preflight install --yes` — fully non-interactive |
| Environment audit | `preflight check` — exits 1 if anything missing, 0 if clean |
| Plugin install fails | Full error reported, nothing swallowed silently |
| Private marketplace | Declare it in `preflight.json`, it registers automatically |

---

## preflight.json

One file. Commit it. That's the whole thing.

```json
{
  "preflight": {
    "required": [
      "security-guidance@claude-plugins-official",
      "brand-voice@company-tools"
    ],
    "recommended": [
      "frontend-design@claude-plugins-official"
    ]
  },
  "marketplaces": {
    "company-tools": {
      "source": "github",
      "repo": "your-org/claude-plugins"
    }
  },
  "versions": {},
  "preflightVersion": "1"
}
```

- `required` — missing plugins are flagged at every session start until installed
- `recommended` — prompted during install, never blocking
- `marketplaces` — private or custom marketplace sources; registered automatically
- `versions` — reserved for v2 version pinning; write `{}` now for forward compatibility

`claude-plugins-official` never needs a `marketplaces` entry — pre-registered in every Claude Code install.

---

## Adding plugins mid-project

You just installed a new plugin and want the team to have it:

```sh
preflight add brand-voice@company-tools
```

Updates `preflight.json`, shows you the commit command. The manifest stays accurate without running init again.

---

## CLI (optional — for terminal and CI usage)

The plugin works fully inside Claude Code without the CLI. Install it separately if you want `preflight install` from the terminal:

```sh
git clone https://github.com/pragyan2002/preflight ~/.preflight
echo 'export PATH="$HOME/.preflight/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Requires: `jq`, `claude` CLI.

```sh
preflight install [--yes]           # install all required plugins
preflight check                     # audit status (exits 1 if missing)
preflight init [--yes]              # scaffold preflight.json
preflight add <plugin@marketplace>  # add to manifest without reinstalling
preflight add <plugin> --recommended
preflight --dir <path>              # use a different project directory
```

**CI / Makefile:**
```makefile
setup:
	preflight install --yes

ci-check:
	preflight check || (echo "Run: preflight install" && exit 1)
```

---

## Multi-tool support

preflight uses an adapter architecture. Claude Code ships in v1. Codex, Cursor, and Windsurf adapters are planned — contributions welcome.

| Tool | Status |
|---|---|
| Claude Code | ✓ v1.0.0 |
| OpenAI Codex | Planned |
| Cursor | Planned |
| Windsurf | Planned |

See [`adapters/README.md`](adapters/README.md) to contribute an adapter.

---

## Requirements

- Claude Code v2.0+
- `jq` — pre-installed on macOS and most Linux distributions
- `claude` CLI — only needed for the optional terminal CLI

---

## Security

The `SessionStart` hook reads two local files only — `preflight.json` and `~/.claude/installed_plugins.json`. No network calls. The CLI installs only from sources you explicitly declared in your manifest.

---

## Roadmap

- **v1.1** — `preflight sync` (install missing + optionally remove unlisted plugins)
- **v2.0** — version constraint enforcement via the `versions` field
- **v2.0** — `preflight.lock.json` for reproducible installs across machines

---

## If preflight saves your team time, leave a star ⭐

It takes two seconds and helps more teams find this.

---

MIT © 2026 Pragyan Shukla
