# dev-clean

A shell script that cleans development caches and build artifacts on macOS and Linux.

**What makes it different:** dev-clean targets **LLM coding tool caches** (Claude Code, Codex, Cursor) that other cleaners don't touch — alongside the usual suspects like `node_modules/.cache`, Rust `target/`, and `.next/` builds.

## What it cleans

| Category | What | Retention |
|----------|------|-----------|
| **Claude Code** | debug logs, file-history, project caches | 1–14 days |
| **Codex** | sessions, archived sessions, logs, worktrees | 7–14 days |
| **Package managers** | npm, pnpm, bun, uv, conda, brew caches | all |
| **Build artifacts** | Rust `target/`, `.next/`, `.turbo/cache` | all |
| **Browsers** | Puppeteer, Playwright downloads | all |
| **macOS extras** | Xcode DerivedData, Archives, Simulator caches | all |
| **Other tools** | Cursor worktrees, opencode caches | all |

## Installation

**One-liner:**

```bash
curl -fsSL https://raw.githubusercontent.com/eyejoker/dev-clean/main/install.sh | bash
```

**Manual:**

```bash
curl -fsSL https://raw.githubusercontent.com/eyejoker/dev-clean/main/dev-clean -o ~/.local/bin/dev-clean
chmod +x ~/.local/bin/dev-clean
```

## Usage

```bash
# Preview what would be deleted (default, safe)
dev-clean

# Actually clean
dev-clean --run

# Show help
dev-clean --help

# Show version
dev-clean --version

# Uninstall (removes script, launchd schedule, and logs)
dev-clean uninstall
```

Example output:

```
=== dev-clean ===
(dry-run mode — nothing will be deleted)

[Claude Code]
  [DRY] debug logs (1d+)                              42 MB (>1d)
  [DRY] projects (14d+)                              180 MB (>14d)
[Package Managers]
  [DRY] npm cache                                    512 MB
  [DRY] pnpm store prune                             (prune unused)
[Build Artifacts]
  [DRY] .next: my-app/.next                          340 MB

=== Total: 1074 MB ===
```

## Configuration

By default, dev-clean scans these directories for build artifacts:

- `~/Developer`
- `~/Projects`
- `~/Documents/GitHub`
- `~/src`
- `~/repos`
- `~/code`

Override with the `DEV_CLEAN_DIRS` environment variable (colon-separated):

```bash
export DEV_CLEAN_DIRS="$HOME/work:$HOME/personal"
dev-clean --dry-run
```

## Scheduling

### macOS (launchd)

The installer lets you choose a schedule (daily / weekly / monthly). To do it manually:

```bash
# install.sh creates this plist — or create your own:
# ~/Library/LaunchAgents/com.eyejoker.dev-clean.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.eyejoker.dev-clean.plist
```

### Linux (cron)

```bash
# Run every Sunday at 3 AM
(crontab -l 2>/dev/null; echo "0 3 * * 0 $HOME/.local/bin/dev-clean --run") | crontab -
```

## Why

Tools like [Mole](https://github.com/tw93/Mole), `npx npkill`, or macOS cleaners handle app caches, `node_modules`, and system junk well. Even Mole's dev cleanup covers npm/pip/cargo/Docker caches thoroughly.

But none of them touch the **CLI-level caches** from LLM coding tools:

| Path | Tool | What accumulates |
|------|------|-----------------|
| `~/.claude/debug/` | Claude Code | Debug logs — hundreds of MB in days |
| `~/.claude/projects/` | Claude Code | Per-project session data |
| `~/.codex/sessions/` | Codex | Full conversation histories |
| `~/.codex/worktrees/` | Codex | Git worktree clones |
| `~/.cursor/worktrees/` | Cursor | Git worktree clones |

> **Note:** Mole cleans the Claude *desktop app* (Electron) rendering cache (`~/Library/Application Support/Claude/Cache`), which is different from the Claude Code *CLI* session data that dev-clean targets.

dev-clean handles all of these in one pass, with sensible retention policies that preserve active sessions. It works alongside Mole or any other cleaner — not as a replacement.

## License

[MIT](LICENSE)
