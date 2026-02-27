# claude-usage-statusline

Show your Claude Pro/Max subscription usage in Claude Code's status line.

<!-- screenshot here -->

## What it shows

- **5-hour window** usage % with reset countdown
- **7-day window** usage %
- **Context window** usage %
- **Model name** (e.g. Opus 4)
- **Project directory**

## Install

```bash
git clone https://github.com/filipores/claude-usage-statusline.git
cd claude-usage-statusline
./install.sh
```

## Uninstall

```bash
./uninstall.sh
```

## Output format

```
⚡ 37% 5h ↻2h05m │ 26% 7d │ ctx:45% │ Opus 4 │ obojobs
```

| Segment | Meaning |
|---------|---------|
| `37% 5h` | 37% of 5-hour rate limit used |
| `↻2h05m` | 5-hour window resets in 2h 5min |
| `26% 7d` | 26% of 7-day rate limit used |
| `ctx:45%` | Context window 45% full |
| `Opus 4` | Active model |
| `obojobs` | Current project directory |

## How it works

1. Reads your OAuth token from macOS Keychain (or Linux credential store)
2. Calls `https://api.anthropic.com/api/oauth/usage` to fetch current limits
3. Caches the response for 60 seconds to avoid excessive API calls
4. Formats everything into a single status line string

Zero dependencies beyond what you already have: bash, python3, and curl.

## Requirements

- macOS or Linux
- Claude Code CLI (logged in)
- python3
- curl

## License

MIT
