# Cold-Start Handoff Template

Use this for the main handoff document. It is the single file a future agent reads first.
Fill sections with real content. Omit a section only when it is truly not applicable.

```markdown
# START HERE — <short task name> (<YYYY-MM-DD>)

**Single cold-start entry point.** Supersedes `<prior handoff path>` if applicable.

## 0. Critical correction

Only include this section if this session disproved or superseded an earlier premise, plan,
handoff, or user assumption.

- Previous assumption:
- Corrected understanding:
- Evidence:
- Do not re-open:

## 1. TL;DR current state

- Goal:
- Current status: <PASSING | BLOCKED | WIP | READY FOR REVIEW | UNKNOWN>
- Furthest confirmed point:
- Main blocker or remaining task:
- Single next action:

## 2. Scope and constraints

- In scope:
- Out of scope:
- Project rules / trust boundaries / security constraints:
- User preferences or decisions that still matter:

## 3. Repository state

- Repo:
- Branch:
- Recent commits:
- Uncommitted changes:
- Untracked/generated/ignored files:
- Files another agent or process owns:

## 4. What changed and why

For each meaningful change:

1. `<path>` — what changed, why, and whether it is committed.
2. `<path>` — what changed, why, and whether it is committed.

## 4b. PR / issue ledger

Every PR and issue touched this session. Keep numbers, links, and state exact.

PRs:

| # | Title | Branch | Base | State (ready/draft/merged/closed) | Purpose (1 line) | Notes (draft/merge-order decision) |
|---|-------|--------|------|-----------------------------------|------------------|------------------------------------|

Issues:

| # | Title | State | Purpose (1 line) | Related issues |
|---|-------|-------|------------------|----------------|

Considered but NOT filed / not opened (discussed and deliberately skipped):

- `<PR or issue idea>` — why it was not created, and whether it should be revisited.

## 5. Evidence and validation

Commands already run:

```bash
<command>
```

Result:

```text
<important output or verdict>
```

Commands not run, with reason:

- `<command>` — <reason>

## 5b. How we debugged (methods)

The investigation approach, so findings are reproducible and extendable — not just their outcomes.

- Method / tool used (adversarial verification, subagent orchestration, trace/log analysis, RE,
  bisect, hand-applying a fix to derisk) → what it established.
- Key probes and the exact command/agent that produced each load-bearing conclusion.

## 6. Decisions made

- Decision:
  - Why:
  - Evidence:
  - Alternatives rejected:

## 7. Open issues and blockers

- Blocker:
  - Symptom:
  - Evidence:
  - Suspected cause:
  - Owner / next action:

## 8. Exact next step

The first action a fresh agent should take, with enough detail to run it immediately.

```bash
<command or edit target>
```

Expected signal:

```text
<what success or failure looks like>
```

Stop and hand off again if:

- <condition>

## 9. Resume commands

From a fresh checkout/session:

```bash
cd <repo>
git status --short
<commands to restore/reproduce current state>
```

Environment variables, services, ports, credentials, or external dependencies needed:

- <item>

## 10. Do not redo

Refuted leads, dead ends, or already-completed work:

- <thing> — <evidence/verdict>

## 11. Running or unfinished agents

For each active/recent agent:

- `<agent name/id>` — <running | completed-not-integrated | died | unknown>, task, owned files,
  last known state, resume doc path.

## 12. Success bar

The handoff is complete when the future agent can verify:

```bash
<command>
```

Expected outcome:

```text
<exact verdict/output>
```
```

Notes:

- Keep the top-level handoff as an index if details are large; link deeper notes instead of pasting logs.
- Prefer exact paths and commands over prose.
- Mark unknowns explicitly. A faithful unknown is better than a guessed answer.
- Redact secrets, tokens, private URLs, and credentials. State where they must be obtained instead.
