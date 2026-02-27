#!/usr/bin/env bash
set -euo pipefail

CACHE="/tmp/claude-usage-cache.json"

# Parse all stdin fields in one python3 call (tab-delimited for spaces in model name)
INPUT=$(cat)
IFS=$'\t' read -r MODEL CTX DIR < <(printf '%s' "$INPUT" | python3 -c "
import sys,json
d=json.load(sys.stdin)
print(d.get('model',{}).get('display_name','?'),
      int(d.get('context_window',{}).get('used_percentage',0)),
      d.get('workspace',{}).get('current_dir','/').rsplit('/',1)[-1], sep='\t')
" 2>/dev/null || echo $'?\t?\t?')

# Fetch OAuth token (macOS keychain, Linux fallback)
get_token() {
  local raw
  if [[ "$(uname)" == "Darwin" ]]; then
    raw=$(security find-generic-password -s "Claude Code-credentials" -a "$(whoami)" -w 2>/dev/null) || return 1
  else
    local cred="$HOME/.claude/.credentials.json"
    [[ -f "$cred" ]] || return 1
    raw=$(cat "$cred")
  fi
  printf '%s' "$raw" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('claudeAiOauth',{}).get('accessToken',''))" 2>/dev/null
}

# Color a percentage: green <50, yellow 50-79, red >=80
color_pct() {
  local p=$1
  if (( p >= 80 )); then printf '\033[31m%d%%\033[0m' "$p"
  elif (( p >= 50 )); then printf '\033[33m%d%%\033[0m' "$p"
  else printf '\033[32m%d%%\033[0m' "$p"; fi
}

# Fetch usage with 60s cache
USAGE=""
if [[ -f "$CACHE" ]] && [[ -z $(find "$CACHE" -mmin +1 2>/dev/null) ]]; then
  USAGE=$(cat "$CACHE")
else
  TOKEN=$(get_token 2>/dev/null || true)
  if [[ -n "$TOKEN" ]]; then
    USAGE=$(curl -s --max-time 3 -H "Authorization: Bearer $TOKEN" -H "anthropic-beta: oauth-2025-04-20" \
      "https://api.anthropic.com/api/oauth/usage" 2>/dev/null || true)
    [[ -n "$USAGE" ]] && printf '%s' "$USAGE" > "$CACHE"
  fi
fi

# Parse usage + compute relative reset time in one python3 call, then output
if [[ -n "$USAGE" ]]; then
  PARTS=$(printf '%s' "$USAGE" | python3 -c "
import sys,json
from datetime import datetime,timezone
d=json.load(sys.stdin)
h5=int(d.get('five_hour',{}).get('utilization',0))
d7=int(d.get('seven_day',{}).get('utilization',0))
r=d.get('five_hour',{}).get('resets_at','').replace('Z','+00:00')
try:
  s=int((datetime.fromisoformat(r)-datetime.now(timezone.utc)).total_seconds())
  rel='now' if s<=0 else f'{s//60}m' if s<3600 else f'{s//3600}h{(s%3600)//60:02d}m'
except: rel='?'
print(h5,d7,rel)
" 2>/dev/null || echo "")
  if [[ -n "$PARTS" ]]; then
    read -r H5 D7 REL <<< "$PARTS"
    printf '\xe2\x9a\xa1 %s 5h \xe2\x86\xbb%s \xe2\x94\x82 %s%% 7d \xe2\x94\x82 ctx:%s%% \xe2\x94\x82 %s \xe2\x94\x82 %s\n' \
      "$(color_pct "$H5")" "$REL" "$D7" "$CTX" "$MODEL" "$DIR"
    exit 0
  fi
fi

# Fallback: no usage data available
printf 'ctx:%s%% \xe2\x94\x82 %s \xe2\x94\x82 %s\n' "$CTX" "$MODEL" "$DIR"
