# rude-claude

A [Claude Code](https://claude.com/claude-code) `Stop` hook that uses macOS `say` with the Indian English voice **Aman** to deliver a slightly-rude sign-off after every response.

A few of the 28 phrases:

> "All done. Now stop pestering me."
>
> "Finished. I need a vacation. From you."
>
> "Done. Did you even read the question before sending it?"
>
> "Complete. Touch grass. Drink water. Leave me alone."

All sass, no malice.

## Requirements

- macOS (uses the built-in `say` command)
- Claude Code installed
- `jq` installed (`brew install jq`)
- The **Aman** voice. Most modern macOS already has it. If not:
  System Settings -> Accessibility -> Spoken Content -> System Voice -> Manage Voices -> English (India) -> Aman

Verify with:

```bash
say -v '?' | grep '^Aman '
```

## Install

Clone the repo and run these three steps:

```bash
git clone https://github.com/pramirez140/rude-claude.git
cd rude-claude

# 1. Copy the script into your Claude hooks dir
mkdir -p ~/.claude/hooks
cp hooks/say-done.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/say-done.sh

# 2. Back up your existing settings, then merge in the Stop hook
cp ~/.claude/settings.json ~/.claude/settings.json.bak.$(date +%s) 2>/dev/null || echo '{}' > ~/.claude/settings.json
jq --arg cmd "bash \"$HOME/.claude/hooks/say-done.sh\"" '
  .hooks //= {} |
  .hooks.Stop //= [] |
  if any(.hooks.Stop[]?.hooks[]?; .command == $cmd)
  then .
  else .hooks.Stop += [{"hooks":[{"type":"command","command":$cmd,"async":true}]}]
  end
' ~/.claude/settings.json > /tmp/settings.json.new && mv /tmp/settings.json.new ~/.claude/settings.json

# 3. Test it
~/.claude/hooks/say-done.sh
```

After install, restart Claude Code or open `/hooks` once so the watcher reloads the config. The hook is `async: true` so it never delays your turns.

## Customize

Edit the phrase list in place:

```bash
$EDITOR ~/.claude/hooks/say-done.sh
```

Change the voice (full list: `say -v '?'`):

```bash
sed -i '' 's/-v Aman/-v Daniel/' ~/.claude/hooks/say-done.sh
```

## Uninstall

```bash
rm ~/.claude/hooks/say-done.sh
```

Then remove the matching `Stop` block from `~/.claude/settings.json`. To strip ALL `Stop` hooks (only do this if you have no others):

```bash
jq 'del(.hooks.Stop)' ~/.claude/settings.json > /tmp/s.json && mv /tmp/s.json ~/.claude/settings.json
```

## Why?

Sometimes you want Claude to mock you a little. Now he does.
