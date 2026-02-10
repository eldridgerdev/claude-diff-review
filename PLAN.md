# Claude Diff Review — Standalone Plugin Plan

## Overview

Turn the existing `diff-review.sh` PreToolUse hook into a
distributable Claude Code plugin that anyone can install with a
single command.

## Why a Claude Code Plugin?

The plugin system natively supports PreToolUse hooks, provides
one-command install via marketplaces, and handles auto-updates.
This is the same pattern used by `safety-net` — a PreToolUse hook
distributed as a plugin.

Alternatives considered:

- **Neovim plugin** — wrong layer; this is triggered by Claude
  Code, not from within neovim
- **npm package** — would still need manual wiring into
  `settings.json`
- **Standalone script + installer** — fragile, no update
  mechanism, no discovery

## Project Structure

```text
claude-diff-review/
├── .claude-plugin/
│   └── plugin.json
├── hooks/
│   └── hooks.json
├── scripts/
│   ├── diff-review.sh
│   ├── feedback-prompt.sh
│   └── explain.sh
├── README.md
└── LICENSE
```

## Adaptations from Current Hook

### 1. Path Resolution

Replace hardcoded `$HOME/.claude/hooks/` references with
`${CLAUDE_PLUGIN_ROOT}/scripts/`. This env var is set by Claude
Code at plugin runtime.

### 2. Declarative Hook Registration

Create `hooks/hooks.json` to register the PreToolUse hook:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/diff-review.sh",
            "timeout": 600
          }
        ]
      }
    ]
  }
}
```

### 3. Cross-Platform Compatibility

The current `stat -f %m` call is macOS-only. Replace with a
portable approach:

```bash
if [[ "$(uname)" == "Darwin" ]]; then
    lock_age=$(( $(date +%s) - $(stat -f %m "$LOCK_DIR") ))
else
    lock_age=$(( $(date +%s) - $(stat -c %Y "$LOCK_DIR") ))
fi
```

### 4. Configurable Activation Delay

Expose `DIFF_REVIEW_DELAY` env var (default 1500ms) instead of
hardcoding the delay before keybindings activate.

### 5. Graceful Dependency Checks

Instead of silently exiting when tmux/nvim are missing, print a
clear error message explaining what's needed:

```text
diff-review: tmux is required but not found.
Install with: brew install tmux (macOS) or apt install tmux (Linux)
```

### 6. Script Extraction

Break the monolithic script into focused pieces:

- `diff-review.sh` — main hook, file capture, vimdiff popup
- `feedback-prompt.sh` — rejection feedback UI
- `explain.sh` — AI-powered diff explanation

## Distribution Strategy

### Primary: cc-marketplace

Submit to `ananddtyagi/cc-marketplace` for community discovery.

```text
/plugin marketplace add ananddtyagi/cc-marketplace
/plugin install diff-review@cc-marketplace
```

### Secondary: Direct GitHub

Users can install directly from the repo:

```text
/plugin marketplace add <user>/claude-diff-review
/plugin install diff-review@claude-diff-review
```

### Stretch: Official Anthropic Directory

Submit a PR to `anthropics/claude-plugins-official` for maximum
visibility.

## Implementation Steps

1. Create a new GitHub repo `claude-diff-review`
2. Scaffold the plugin directory structure
3. Write `plugin.json` manifest with metadata
4. Write `hooks/hooks.json` for PreToolUse registration
5. Refactor `diff-review.sh`:
   - Use `${CLAUDE_PLUGIN_ROOT}` for paths
   - Fix Linux `stat` compatibility
   - Extract feedback/explain scripts
   - Add configurable delay via env var
   - Add dependency check with helpful error messages
6. Write README with:
   - Demo GIF / screenshots
   - Prerequisites (tmux, nvim)
   - Install instructions
   - Configuration options
7. Validate with `claude plugin validate .`
8. Publish to GitHub
9. Submit to cc-marketplace

## Prerequisites for Users

- Claude Code (latest)
- tmux (for display-popup)
- neovim (for vimdiff with treesitter)
- jq (for JSON parsing)
- claude CLI (for the explain feature)
