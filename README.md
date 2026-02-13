# claude-diff-review

Review Claude Code file changes in a vimdiff popup before they're
applied.

Every time Claude uses the Edit or Write tool, a tmux popup opens
showing the original file alongside the proposed changes. You can
approve, reject with feedback, ask for an AI explanation, or
cancel — all without leaving your terminal.

## Why

If I am working on a project that is well established and I let an
AI agent go wild without checking it's work I often spend more time
reviewing and fixing bugs and bad code. Even if I try to watch the
agent and accept every diff manually, my eyes glaze over looking at
Claude Code's diff

### ugh
<img width="1896" height="1030" alt="image" src="https://github.com/user-attachments/assets/71c2b959-98a2-47e4-867d-0f3657b590ff" />

## Enter Claude-Diff-Review
Now I can look at the changes side by side in my own NVIM environment.
This lets me use treesitter for syntax highlighting, jumping, and more.
I can easilly use "redo" to tell the AI to do something different.
If I still have no idea what is going on, I can even have the AI
explain it to me

### much better
<img width="1896" height="1030" alt="image" src="https://github.com/user-attachments/assets/e4728f01-e607-4e3d-922b-526b3e9bc5f5" />

## Features

- **Side-by-side vimdiff** with treesitter syntax highlighting
- **Reject with feedback** — tell Claude what to do differently
- **AI explain** — get a plain-English summary of the changes
- **Activation delay** — prevents accidental approvals when the
  popup steals focus
- **Concurrency lock** — serializes reviews when Claude makes
  rapid edits
- **New file detection** — shows a single-pane view for new files

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- [tmux](https://github.com/tmux/tmux) (for the popup window)
- [neovim](https://neovim.io/) (for vimdiff with treesitter)
- [jq](https://jqlang.github.io/jq/) (for JSON parsing)
- [claude CLI](https://docs.anthropic.com/en/docs/claude-code)
  (optional, for the explain feature)

## Install

### From a marketplace

```bash
# Add the marketplace (one-time)
claude plugin marketplace add <marketplace>

# Install the plugin
claude plugin install diff-review@<marketplace>
```

### From GitHub

```bash
claude plugin marketplace add eldridger/claude-diff-review
claude plugin install diff-review@claude-diff-review
```

### Manual

Clone this repo and add the hook to your
`~/.claude/settings.json` manually:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/claude-diff-review/scripts/diff-review.sh",
            "timeout": 600
          }
        ]
      }
    ]
  }
}
```

## Usage

Once installed, the review popup appears automatically whenever
Claude proposes a file change. No configuration needed.

### Keybindings (inside the popup)

| Key     | Action                                    |
| ------- | ----------------------------------------- |
| `Enter` | Approve the change                        |
| `r`     | Reject — prompts for feedback             |
| `e`     | Explain — AI summary of the changes       |
| `q`     | Cancel the change                         |

Keys are locked for a short delay after the popup opens to prevent
accidental input.

## Configuration

All configuration is via environment variables:

| Variable             | Default | Description                        |
| -------------------- | ------- | ---------------------------------- |
| `DIFF_REVIEW_DELAY`  | `1500`  | ms before keybindings activate     |

Export these in your shell profile (e.g. `.bashrc`, `.zshrc`,
`config.fish`) to customize behavior.

The plugin uses `nvim --clean` so no user Neovim configuration
is required or loaded.

## How It Works

1. Claude Code fires a `PreToolUse` hook before each Edit/Write
2. The hook captures the original file and reconstructs the
   proposed version
3. A tmux popup opens with `nvim -d` showing both versions
4. Your decision is communicated back to Claude Code via the
   hook's exit code and stderr

## Troubleshooting

If the explain feature shows a blank screen, ensure the `claude`
CLI is installed and in your PATH, or set `CLAUDE_CMD` to its
full path.

## License

MIT
