#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

CLAUDE_DIR="$HOME/.claude"
DEST="$CLAUDE_DIR/statusline-usage.sh"
SETTINGS="$CLAUDE_DIR/settings.json"

# Remove the statusline script
rm -f "$DEST"
echo -e "${GREEN}✓${NC} Removed statusline-usage.sh"

# Remove statusLine key from settings.json
if [ -f "$SETTINGS" ]; then
    python3 -c "
import json
path = '$SETTINGS'
with open(path) as f:
    settings = json.load(f)
settings.pop('statusLine', None)
with open(path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
"
    echo -e "${GREEN}✓${NC} Removed statusLine from settings.json"
fi

echo ""
echo "Restart Claude Code for changes to take effect."
