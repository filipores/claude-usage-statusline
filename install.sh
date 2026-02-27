#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
DEST="$CLAUDE_DIR/statusline-usage.sh"
SETTINGS="$CLAUDE_DIR/settings.json"

# Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"

# Copy the statusline script
cp "$SCRIPT_DIR/statusline.sh" "$DEST"
chmod +x "$DEST"
echo -e "${GREEN}✓${NC} Copied statusline-usage.sh to $CLAUDE_DIR"

# Update settings.json with python3 (preserves existing settings)
python3 -c "
import json, os
path = '$SETTINGS'
settings = {}
if os.path.exists(path):
    with open(path) as f:
        settings = json.load(f)
settings['statusLine'] = {
    'type': 'command',
    'command': 'bash ~/.claude/statusline-usage.sh'
}
with open(path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
"
echo -e "${GREEN}✓${NC} Updated settings.json with statusLine config"

echo ""
echo "Restart Claude Code for changes to take effect."
