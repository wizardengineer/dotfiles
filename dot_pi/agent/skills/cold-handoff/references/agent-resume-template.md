# Agent Resume Template

Use this for each active, failed, or unfinished agent whose work is not fully integrated into the
main handoff. Write the file as `agents/RESUME-<agent-name>.md` next to the main handoff.

```markdown
# RESUME — <agent-name> (<RUNNING | COMPLETED-NOT-INTEGRATED | DIED | UNKNOWN>)

## Mission

What this agent was asked to do, in its own scope. Include the success condition.

## Last known state

- Last status:
- Last action/tool/command:
- Last useful output:
- If running: when it was last observed and what it may still be doing.
- If died: error, crash, timeout, or interruption details.

## Findings

- Finding:
  - Evidence:
  - Confidence:

## Changes made

- `<path>` — what changed, committed/uncommitted/reverted, and why.

## Owned files or resources

Files, services, worktrees, ports, queues, devices, or external resources this agent owns or must
not collide with.

- <resource>

## Exact next action

The first concrete action to resume this agent's work.

```bash
<command or edit target>
```

Expected signal:

```text
<success/failure signal>
```

## Context required

- Relevant paths:
- Commands already tried:
- Constraints and project rules:
- Gotchas:

## Coordination notes

- Other agents/tasks that interact with this work:
- What this agent must not touch:
- Where to write final results or a follow-up handoff:
```

Notes:

- Keep this resume focused on this agent only. Shared project state belongs in the main handoff.
- Do not claim a running agent finished unless there is evidence.
- If the agent owns uncommitted work, state the exact files and whether a fresh agent may edit them.
