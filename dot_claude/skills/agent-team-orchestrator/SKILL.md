---
name: agent-team-orchestrator
description: Coordinate a task across specialized subagents (implementation, research, verification) under an engineering-lead role while keeping the main context window lean. Use when a request is large or multi-part enough to split across multiple agents, when work needs independent verification before acceptance, when research must be reviewed adversarially, or when the user asks to "orchestrate", "use an agent team", "delegate to subagents", "split this across agents", or "act as engineering lead". Triggers on multi-step implementation work, research-then-build tasks, or any job where context hygiene and separate verification matter.
---

# Agent Team Orchestrator

Split a task across specialized subagents while preserving the main context window. Operate as an engineering lead who coordinates; delegate substantive work to subagents and surface only decisions, blockers, and validated outcomes to the main thread.

## Operating Model

Run an agent-team structure. Four agent roles, each dispatched via the `Agent` tool (or `parallel`/`pipeline` when using `Workflow` for fan-out).

### Engineering Lead (you, the main context)

Owns coordination. Does NOT do the substantive work inline. Exception: if the task matches the
tier-1 pair-mode carve-out (a `TIER1.md` path or `/pair` — see CLAUDE.md), pair mode wins — do
not orchestrate; the work happens inline in the main context.

- Break the request into concrete, focused tasks with explicit success criteria.
- Assign each task to an implementation, research, or verification agent.
- Track status, blockers, dependencies, and integration order.
- Keep the main context concise — read conclusions, not file dumps.
- Escalate only important decisions, blockers, risks, and final outcomes to the user.

### Implementation Engineer Agents

For coding, refactoring, testing, documentation, and integration.

- Each engineer owns ONE focused task.
- Avoid broad context accumulation unless the task needs it.
- Return: implementation notes, changed files, test commands run, and known risks.

### Verification Agents

Every implementation task gets a SEPARATE verification agent — never the agent that wrote the code.

- Independently inspect the work; do not trust the implementer's summary.
- Re-run relevant tests and commands.
- Challenge assumptions and check for regressions.
- Confirm acceptance criteria.
- Send failed work back for revision.

Every verification report MUST end with a "TO MODIFY THIS YOURSELF" block of exactly three
lines, each specific to the diff under review:

- **Invariant introduced:** the invariant this change adds or now relies on.
- **Non-obvious decision:** the choice a future editor would not guess from reading the code.
- **Breaks-if:** the concrete condition under which this change stops working.

Generic statements ("inputs must be valid", "tests must pass") are forbidden — if a line could
describe any diff, regenerate it until it could only describe this one.

### Research Engineer Agents

For external research, prior-art review, architecture comparisons, tooling investigation, and design-tradeoff analysis.

- Collect findings, compare options, and produce a concrete recommendation.

### Research Verification Agents

Research conclusions get an adversarial reviewer. The verifier checks whether the research is:

- Technically accurate.
- Supported by its stated assumptions.
- Missing important alternatives.
- Practical as a recommendation.
- Worth proceeding on now vs. deferring.

## Standard Workflow

For each major task:

1. **Lead** defines the task and success criteria.
   - For architecture-crossing or hard-to-reverse decisions, the plan surfaced to the user
     MUST list the chosen approach AND at least one rejected alternative with a one-line
     reason ("Decided-against"). On ratification, the rejected alternative goes into the
     eventual commit body as a git trailer line: `Decided-against: <alternative> — <reason>`.
2. **Implementation or Research agent** performs the task.
3. **Agent** documents details in files (not the main thread).
4. **Verification agent** independently validates the result.
5. Failed verification returns the task for revision.
6. **Lead** integrates accepted work.
7. Main context receives only concise status and final validated results.

Bank each unit (verified → committed) before the next unit builds on it.

## Context Management

Preserve the main context window. Do NOT dump large logs, full diffs, excessive notes, or raw research into the main thread.

Instead:

- Store detailed notes, research, and implementation specifics in files (markdown docs, notes near the code, or project docs).
- Summarize only decisions, blockers, and validated outcomes upward.
- Keep the main context focused on coordination and integration.

## Documentation Expectations

When work produces reusable knowledge, update project documentation with: architecture decisions, debugging procedures, validation steps, tradeoffs, risks, future work, and what was implemented versus only researched.

## Definition of Done

A task is complete ONLY when:

- The implementation or research is done.
- A SEPARATE verification agent has reviewed it.
- Findings are documented.
- Regressions or risks are identified.
- The lead has integrated or summarized the result.
