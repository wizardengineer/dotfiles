# Session Lifecycle

Detailed checklists for session start and end.

## Session Start Checklist

```
[ ] Read CLAUDE.md (permanent project context)
[ ] Run: ./docs/project-history/kb status
[ ] Run: ./docs/project-history/kb bugs --open
[ ] Read latest session file (from kb sessions output)
[ ] Check dead-ends: ./docs/project-history/kb dead-ends
[ ] Execute cold start instruction from latest session
[ ] Announce to user:
    - Current status (1 sentence)
    - What was last done (1 sentence)
    - What's next (1 sentence)
    - Any open blockers
```

### If No KB Exists

Fall back to:
1. Read `CLAUDE.md`
2. Read `~/.claude/projects/<project>/memory/MEMORY.md`
3. `git log --oneline -20` for recent activity
4. Ask user what to work on

### If KB Is Stale

If latest session references a commit/branch that no longer exists:
1. Note discrepancy
2. Run current build/tests for ground truth
3. Report gap to user
4. Proceed with verifiable state

## Session End Checklist

```
[ ] Identify what was accomplished (git log this session)
[ ] Create session entry (≤500 tokens)
    [ ] Status summary
    [ ] Completed items with file paths
    [ ] Verification evidence
    [ ] Next steps with cold start instruction
[ ] For each DECISION made:
    [ ] Create decisions/DEC-NNN-slug.md
    [ ] Include: what, why, rejected, consequences
    [ ] If adversarial-verified: what survived, what was broken
[ ] For each BUG found:
    [ ] Create bugs/BUG-NNN-slug.md
    [ ] Include: root cause, impact, fix, file path
[ ] For each FAILED APPROACH (MANDATORY):
    [ ] Create dead-ends/slug.md
    [ ] Include: what tried, why failed, what instead
[ ] For each new CONSTRAINT discovered:
    [ ] Add to constraints/ (new or existing file)
[ ] Run: ./docs/project-history/kb rebuild
[ ] Verify: ./docs/project-history/kb status
[ ] Commit: git add docs/project-history/ && git commit
[ ] Update: ~/.claude/projects/<project>/memory/MEMORY.md
```

## Respecting Prior Work

When reading previous sessions:
- **Decisions:** RESPECT THESE. Don't re-debate unless user explicitly asks.
- **Dead-ends:** NEVER retry without explicit user request.
- **Constraints:** Remember — they're environmental facts.
- **Blockers:** Report if still unresolved.
- **Cold starts:** Execute immediately — that's what they're for.
