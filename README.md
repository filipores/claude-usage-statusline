# claude-usage-statusline

Show your Claude Pro/Max subscription usage in Claude Code's status line.

<!-- screenshot here -->

## What it shows

- **5-hour window** usage % with reset countdown
- **7-day window** usage % (only shown when applicable)
- **Context window** usage %
- **Model name** (e.g. Opus 4)
- **Project directory** with git branch

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
⚡ 87% ↻1h18m │ ctx:69% │ Opus 4 │ obojobs(main)
```

| Segment | Meaning |
|---------|---------|
| `87%` | 87% of 5-hour rate limit used (color-coded: green/yellow/red) |
| `↻1h18m` | 5-hour window resets in 1h 18min |
| `ctx:69%` | Context window 69% full |
| `Opus 4` | Active model |
| `obojobs(main)` | Project directory and git branch |

On plans with a 7-day limit (e.g. Pro), an additional `26% 7d` segment is shown.

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
