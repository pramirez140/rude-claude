#!/usr/bin/env bash
# rude-claude installer
# Adds Aman's slightly-rude Stop hook to your Claude Code settings.
#   curl -fsSL https://raw.githubusercontent.com/pramirez140/rude-claude/main/install.sh | bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/pramirez140/rude-claude/main"
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"
SCRIPT_DEST="$HOOKS_DIR/say-done.sh"
HOOK_CMD="bash \"$SCRIPT_DEST\""

err() { echo "rude-claude: $*" >&2; exit 1; }
say_ok() { echo "rude-claude: $*"; }

[ "$(uname)" = "Darwin" ] || err "macOS only (this hook uses the 'say' command)."
command -v say >/dev/null 2>&1 || err "'say' command not found."
command -v jq  >/dev/null 2>&1 || err "'jq' is required. Install: brew install jq"
command -v curl >/dev/null 2>&1 || err "'curl' is required."

if ! say -v '?' 2>/dev/null | grep -q '^Aman '; then
  echo "rude-claude: WARNING - the Aman voice is not installed."
  echo "  System Settings -> Accessibility -> Spoken Content -> System Voice -> Manage Voices -> English (India) -> Aman"
  echo "  (continuing anyway; macOS will fall back to a default voice)"
fi

mkdir -p "$HOOKS_DIR"

# Get the script: prefer a colocated copy (clone install), else fetch from GitHub
if [ -f "$(dirname "$0")/hooks/say-done.sh" ]; then
  cp "$(dirname "$0")/hooks/say-done.sh" "$SCRIPT_DEST"
else
  curl -fsSL "$REPO_RAW/hooks/say-done.sh" -o "$SCRIPT_DEST"
fi
chmod +x "$SCRIPT_DEST"
say_ok "installed $SCRIPT_DEST"

# Ensure settings.json exists, then back up
[ -f "$SETTINGS" ] || echo "{}" > "$SETTINGS"
cp "$SETTINGS" "$SETTINGS.bak.$(date +%s)"

# Idempotent merge: skip if our exact command is already there
if jq -e --arg cmd "$HOOK_CMD" '.hooks.Stop[]?.hooks[]? | select(.command == $cmd)' "$SETTINGS" >/dev/null 2>&1; then
  say_ok "Stop hook already configured. Nothing to merge."
else
  TMP=$(mktemp)
  jq --arg cmd "$HOOK_CMD" '
    .hooks //= {} |
    .hooks.Stop //= [] |
    .hooks.Stop += [{"hooks":[{"type":"command","command":$cmd,"async":true}]}]
  ' "$SETTINGS" > "$TMP" && mv "$TMP" "$SETTINGS"
  say_ok "Stop hook added to $SETTINGS"
fi

say_ok "testing voice (you should hear Aman now)..."
"$SCRIPT_DEST" || true

cat <<'EOF'

Installed. Restart Claude Code or open /hooks once so the watcher reloads the config.
The hook is async, so it never delays your turns.

Customize:  $EDITOR ~/.claude/hooks/say-done.sh
Uninstall:  rm ~/.claude/hooks/say-done.sh  (then strip the Stop block from settings.json)
EOF
