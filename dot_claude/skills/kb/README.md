# kb — Project Knowledge Base Skill

Session continuity system for AI-assisted development. One CLI + one skill = restore context, save progress, query history, prevent dead-end retries.

## Quick Start

```bash
# First-time setup (creates docs/project-history/ in your project)
~/.claude/skills/kb/scripts/kb init

# Session start — restore context from last session
~/.claude/skills/kb/scripts/kb start

# Session end — save progress with template
~/.claude/skills/kb/scripts/kb save

# Query anything
~/.claude/skills/kb/scripts/kb bugs --open
~/.claude/skills/kb/scripts/kb decisions
~/.claude/skills/kb/scripts/kb dead-ends
~/.claude/skills/kb/scripts/kb search "aligned_alloc"
```

## How It Works

```
/kb skill (instructions)  →  kb CLI (engine)  →  docs/project-history/ (data)
     ~/.claude/skills/kb/       scripts/kb          in your project repo
```

**Skill** tells the agent WHEN and HOW to use the CLI.
**CLI** reads/writes files in `docs/project-history/`.
**Data** lives in your project repo, version-controlled with git.

## File Structure

```
~/.claude/skills/kb/
├── SKILL.md                        # Agent instructions (loaded on trigger)
├── README.md                       # This file
├── scripts/
│   └── kb                          # CLI tool (bash, zero deps)
└── references/
    ├── changelog-principles.md     # Token budgets, anti-duplication, adversarial verification
    ├── entry-formats.md            # YAML front matter templates for all entry types
    └── session-lifecycle.md        # Detailed start/end checklists
```

## Project Data Structure

Created by `kb init` in your project repo:

```
docs/project-history/
├── INDEX.md              # Generated — project overview
├── sessions/             # What happened (chronological)
│   ├── INDEX.md          # Generated — session list
│   └── 001-slug.md       # Session entries with YAML front matter
├── decisions/            # Why things are the way they are (ADR-style)
├── bugs/                 # What broke and how it was fixed
├── constraints/          # Environmental facts (platform quirks, limits)
└── dead-ends/            # What NOT to try again (failed approaches)
```

## CLI Commands

| Command | Purpose |
|---------|---------|
| `kb start` | **Read:** Restore context — status, bugs, dead-ends, cold start |
| `kb save` / `kb end` | **Write:** Save session — template with git info |
| `kb status` | Project overview (counts + latest session) |
| `kb sessions` | List all sessions |
| `kb session N` | Show specific session |
| `kb decisions` | Decision registry |
| `kb bugs [--open]` | Bug list |
| `kb dead-ends` | Failed approaches (DO NOT RETRY) |
| `kb constraints` | Environmental facts |
| `kb search term` | Cross-category grep |
| `kb rebuild` | Regenerate INDEX.md files from source |
| `kb init` | First-time setup |

## Key Principles

- **500-token session entries** — lean, pointer-based (never duplicate CLAUDE.md)
- **Cold start instructions** — every session ends with one sentence telling the next session exactly what to do first
- **Dead-ends are mandatory** — if something was tried and abandoned, document it. Prevents retry waste.
- **INDEX.md is generated** — run `kb rebuild`, never edit manually. Indexes never drift from source.
- **Adversarial verification for decisions** — prover + breaker agents debate, document what survived

## Triggers

The skill activates on: `/kb`, "save progress", "restore context", "continue where left off", "what bugs", "what decisions", "session start", "session end".
