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

## Install (one-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/pramirez140/rude-claude/main/install.sh | bash
```

The installer:
1. Copies `say-done.sh` to `~/.claude/hooks/` and `chmod +x`
2. Backs up `~/.claude/settings.json` and merges in the `Stop` hook (idempotent — re-running is safe)
3. Plays one phrase to confirm it works

After install, restart Claude Code or open `/hooks` once so the watcher reloads the config. The hook is `async: true`, so it never delays your turns.

## Install (clone)

```bash
git clone https://github.com/pramirez140/rude-claude.git
cd rude-claude
./install.sh
```

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
