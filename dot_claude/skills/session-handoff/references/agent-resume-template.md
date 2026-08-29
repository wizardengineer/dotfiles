# Agent Resume Template

One file per running/recently-finished agent: `agents/RESUME-<agent-name>.md`. Purpose: let that
agent (or a fresh one with NO context) continue exactly where it left off. Fill with real values.

```markdown
# RESUME — <agent-name>  (<status: RUNNING | DIED | COMPLETED-not-banked>)

## Mission (one paragraph)
What this agent was tasked to do, in its own scope. The success condition.

## Where it left off  (the critical part)
- Last confirmed state / last action taken.
- If STILL RUNNING when handed off: say so + its last reported progress (it may finish or die).
- If it DIED (crash/error): the error and the last tool/step before it.
- What it had already FOUND (findings, measurements, oracle results) — so this isn't re-derived.
- What it had already CHANGED (files touched; committed? hash? or uncommitted/reverted?).

## The exact next action
The single next concrete step to take. Be specific: the function/address/test, the command,
the expected signal. If a hypothesis was mid-test, state it and how to confirm/refute it.

## Context it needs (no prior memory assumed)
- Key facts / decoded values / addresses it was working with.
- Files it owns or edits (so a parallel agent doesn't collide).
- Exact setup + reproduce commands (build, env flags, run, the probe/verify command).
- Tooling + gotchas specific to its task.

## Hard rules it was operating under
The constraints to preserve (e.g. no band-aids, preserve baseline X, anti-cascade: stop after the
first real divergence, don't edit generated files, commit-only-if-green, revert-on-regression).

## Coordination
- Other agents running and the resource each owns (e.g. only one drives the emulator / runtime /
  the build tree at a time). What this agent must NOT touch.
- Where to write its own handoff/writeup when it finishes or stops.
```

Notes:
- If multiple agents ran, one file each; the main handoff's "Running agents" section links them all.
- For a still-running background agent, this doc is the **recovery path**: if it dies mid-run, a
  fresh agent reads this and resumes without re-doing the investigation.
- Keep each resume doc focused on ITS task; shared project context lives in the main handoff.
