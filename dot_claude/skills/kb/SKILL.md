---
name: kb
description: "Project Knowledge Base — unified system for session continuity, decision tracking, bug history, and context restoration. Use /kb at session start to restore context, at session end to save progress, or anytime to query project history. Triggers: 'session start', 'save progress', 'what happened', 'what bugs', 'what decisions', 'continue where left off', 'restore context', 'end of session', 'what failed'."
---

# Project Knowledge Base

CLI (`scripts/kb`) + skill = one system. Restore context, save progress, query history, prevent dead-end retries.

The CLI script lives at `~/.claude/skills/kb/scripts/kb`. It auto-discovers `docs/project-history/` in the current project by walking up from cwd.

## Session Lifecycle Commands

```bash
kb start              # READ: Restore context — status + bugs + dead-ends + cold start
kb save               # WRITE: Save session — template + git info + next steps
kb end                # Alias for save
```

## Session Start (read-changelog)

Run `kb start`. It automatically:
1. Shows project status (session count, bug count, etc.)
2. Lists open bugs
3. Lists dead-ends (DO NOT RETRY reminders)
4. Shows the cold start instruction from the latest session

Then read the latest session file for full context and execute the cold start.

## Session End (write-changelog + save-changelog)

Run `kb save`. It automatically:
1. Shows the next session number
2. Gathers git branch and recent commits
3. Prints a fill-in template for the session entry

Then you:
1. Fill in the template → save as `docs/project-history/sessions/NNN-slug.md`
2. Extract decisions → `decisions/DEC-NNN-slug.md`
3. Extract bugs → `bugs/BUG-NNN-slug.md`
4. Extract dead-ends → `dead-ends/slug.md` (**MANDATORY** if anything failed)
5. Run `kb rebuild` then `kb status` to verify
6. `git add docs/project-history/ && git commit`

See [references/entry-formats.md](references/entry-formats.md) for YAML templates.

## Query Commands

```bash
kb status              # Overview + latest session
kb sessions            # List all sessions
kb session <N>         # Full session detail
kb decisions           # Decision registry
kb bugs [--open]       # Bug list (optionally open only)
kb dead-ends           # Failed approaches — DON'T RETRY
kb constraints         # Environmental facts
kb search <term>       # Cross-category grep
kb rebuild             # Regenerate INDEX.md from source
kb init                # First-time setup — create directory structure
```

## Rules

1. **YAML front matter on every file** — makes kb queryable
2. **One concern per file** — one bug, one decision, one dead-end
3. **Never edit INDEX.md** — `kb rebuild` generates it
4. **Dead-ends MANDATORY** — highest-value category, prevents retry waste
5. **Session entries ≤ 500 tokens** — pointer-reference CLAUDE.md, don't duplicate
6. **Cold start instruction MANDATORY** — one sentence, one action, one file
7. **Monotonic IDs** — 001, 002... / BUG-001... / DEC-001... never reuse
8. **Verify before commit** — `kb status` after rebuild
9. **Adversarial verification for decisions** — prover + breaker, document what survived

## Reference Docs

- [references/changelog-principles.md](references/changelog-principles.md) — WHY entries are structured this way
- [references/entry-formats.md](references/entry-formats.md) — YAML templates for all entry types
- [references/session-lifecycle.md](references/session-lifecycle.md) — Detailed start/end checklists
