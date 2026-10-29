# claude-statusline

A fast, minimal status line for [Claude Code](https://claude.com/claude-code).

![preview](preview.svg)

Model, effort, context, git branch with changed lines, weekly and 5-hour limits with reset time.
Colors go from green to red as usage grows.

## Install

Paste into Claude Code:

```
Install https://github.com/nicknotknack/claude-statusline as my status line
```

Or by hand (needs `jq` and a [Nerd Font](https://www.nerdfonts.com/) for icons, built into Ghostty):

```sh
curl -fsSL https://raw.githubusercontent.com/nicknotknack/claude-statusline/main/statusline.sh -o ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

and add to `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "~/.claude/statusline.sh" }
```

## License

MIT
