---
name: preflight-resolver
description: Diagnose and recover from plugin dependency failures. Use proactively when a plugin install fails, when /preflight:install or `preflight install` reports errors, when the session-start hook fires repeatedly despite installing, or when the user is confused about the preflight.json format.
effort: low
---

# Plugin dependency resolver

## When to invoke

- `/preflight:install` or `preflight install` reports failures
- "Plugin not found" or "marketplace not registered" errors
- Session-start warning fires every session despite running install
- User confused about manifest format

## Diagnostic paths

### Plugin not found

1. Confirm format is `name@marketplace` (case-sensitive).
2. Check marketplace is registered: `claude plugin marketplace list`
3. If missing: `claude plugin marketplace add {owner}/{repo}` then retry.
4. Check scope conflicts: `claude plugin list`.

### Hook fires every session despite install

Key in `installed_plugins.json` doesn't match manifest declaration. Run `preflight check` or `/preflight:check` to compare installed key vs manifest key side by side.

### Manifest validation errors

Valid `preflight.json` schema:
```json
{
  "preflight": {
    "required": ["plugin-name@marketplace"],
    "recommended": ["plugin-name@marketplace"]
  },
  "marketplaces": {
    "marketplace-name": { "source": "github", "repo": "owner/repo" }
  },
  "versions": {},
  "preflightVersion": "1"
}
```

Common mistakes:
- `"preflightVersion": 1` (number not string)
- Missing `@marketplace` suffix
- Marketplace name mismatch
- `.preflight.required` is an object not an array
- `claude-plugins-official` in `.marketplaces` (unnecessary)
- `"versions"` field absent (add it as `{}` for forward compatibility)

### CLI not found

`preflight install` requires the CLI on PATH. The skills work without it.
Install CLI:
```sh
git clone https://github.com/pragyan2002/preflight ~/.preflight
echo 'export PATH="$HOME/.preflight/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```
