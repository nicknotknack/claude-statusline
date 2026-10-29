# claude-statusline

A minimal status line for [Claude Code](https://claude.com/claude-code).

```
Opus 5.5 · high · context: 63% ·  main +12 −3            week: 12% · session: 91% ↻ 17:20
```

- **Left:** model, effort, context usage, git branch with added/removed lines
- **Right:** weekly and 5-hour session limits, session reset time
- Colors change with usage: green, then yellow/orange, then red

## Requirements

- `bash`, `jq`, `git`
- A [Nerd Font](https://www.nerdfonts.com/) for the branch icon

## Install

Paste this into Claude Code:

```
Install this status line: download https://raw.githubusercontent.com/nicknotknack/claude-statusline/main/statusline.sh to ~/.claude/statusline.sh, make it executable, and set "statusLine": {"type": "command", "command": "~/.claude/statusline.sh"} in ~/.claude/settings.json. Install jq if missing.
```

Or do it yourself:

```sh
curl -fsSL https://raw.githubusercontent.com/nicknotknack/claude-statusline/main/statusline.sh -o ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

Then add this to `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "~/.claude/statusline.sh" }
```

## License

MIT
