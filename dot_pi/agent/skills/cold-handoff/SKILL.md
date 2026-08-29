---
name: cold-handoff
description: >-
  Create a self-contained cold-start handoff for a future agent or session with
  no prior context. Use when wrapping up work, pausing before context is lost,
  handing work to Claude Code, Pi, Codex, or another agent, recording current
  truth after a long investigation, or when the user says "cold handoff",
  "handoff", "wrap this up", "save context", "resume later", or "start here".
---

# Cold Handoff

Create a durable handoff that lets a fresh agent resume without conversation history.
Optimize for correctness and recoverability over brevity.

## Deliverables

1. One cold-start handoff document: the single file a future agent reads first.
2. Optional per-agent resume documents for active, background, or unfinished subagents.
3. A concise final report with the handoff path, current state, validation, and exact next step.

Do not push. Do not commit unless the user explicitly asked to bank/commit the work or the repo has a clear handoff convention that requires it. If important work remains uncommitted, document it clearly in the handoff.

## Workflow

### 1. Find the handoff location

Work in the current repository when inside one. Otherwise use the current working directory.

Prefer an existing convention, in this order:

- `.planning/handoff/`, `docs/handoff/`, `handoff/`, or `handoffs/`
- an existing `HANDOFF.md`, `STATE.md`, `STATUS.md`, `.continue-here.md`, or `*-START-HERE.md`
- project instructions in `CLAUDE.md`, `AGENTS.md`, or README files

If no convention exists, create `handoff/` and write `01-START-HERE.md`. If numbered `*-START-HERE.md` files already exist, write the next number. If date-based handoffs are the local convention, follow it.

### 2. Gather current truth

Collect only evidence needed to resume accurately:

- User goal and current task, as understood now.
- Relevant project instructions (`CLAUDE.md`, `AGENTS.md`, local docs) that affect future work.
- Git state: `git status --short`, branch, recent commits, and `git diff --stat` when in a git repo.
- Modified/untracked files and which are generated, ignored, intentionally uncommitted, or owned by another process/agent.
- Commands already run and their outcomes: tests, linters, builds, repro steps, debugging probes.
- **The debugging approach itself, not just outcomes** — the methods, tools, and probes used to
  reach each finding (e.g. adversarial verification, agent-team orchestration, trace/log analysis,
  bisecting, reverse-engineering, hand-applying a fix to derisk before automating). A future agent
  needs to know *how* a conclusion was established so it can extend or re-run it, and so it does not
  redo the investigation from scratch.
- Decisions made, assumptions invalidated, blockers, and the exact current furthest point.
- **What NOT to do** — refuted leads, settled calls, upstream-impossible goals, and any action that
  was explicitly denied or is gated on the user (spend, outward push, out-of-scope). State these so
  the next agent does not burn effort re-attempting them.
- **What to do next** — the single first action, plus the decision(s) still owed by the user.
- Active or recently completed background agents/subagents, their tasks, last known status, and owned files.
- **Every PR and issue touched this session** — opened, drafted, edited, commented on, closed, or
  merely considered/discussed-but-not-created. For each, capture: number + link, title, state
  (open/draft/ready/merged/closed, and for a stack which PR is its base), what it changes, and any
  deliberate draft-state or merge-order decision. Include "thought about / talked about but did not
  file" as an explicit list so the next session neither forgets them nor re-files duplicates.
- Options **considered and rejected** (and why), so a future agent does not re-open a settled call.

If a command could execute untrusted project artifacts or have side effects, do not run it merely for the handoff. Prefer recording the last known result and the command a future agent should run.

### 3. Reconcile stale context

Before writing, identify whether this session disproved or superseded an earlier premise, plan, handoff, or user assumption.

If yes, put a **Critical correction** at the top of the handoff. State what was wrong, the corrected understanding, and what not to re-open.

### 4. Write the cold-start handoff

Load `references/cold-start-handoff-template.md` and fill it with real content. The document must stand alone:

- Use exact paths, branch names, commands, error messages, ports, issue/PR numbers, and commit hashes where relevant.
- Prefer relative links between repo files.
- Mark unknowns as unknown; do not invent certainty.
- Omit truly irrelevant sections, but do not leave placeholders.
- Include the single next action a fresh agent should take first.
- Include a **"How we debugged" element**: the investigation methods that produced the findings
  (adversarial verification, subagent orchestration, trace analysis, RE, hand-proofs), so they are
  reproducible and extendable rather than opaque conclusions.
- Include an explicit **"What NOT to do"** section (refuted leads, denied actions, upstream-impossible
  goals) and a **"What to do next"** section (first action + user-owed decisions).
- Include a **PR/issue ledger**: a table or list of every PR and issue from this session (opened,
  drafted, ready, merged, closed, or considered-but-not-filed) with number, link, base branch (for
  stacked PRs), state, one-line purpose, and any draft-state / merge-order / rebase decision. Add a
  short "considered but not done" list of PRs/issues that were discussed and deliberately skipped,
  with the reason, so they are neither lost nor duplicated.

### 5. Write per-agent resume docs when needed

If any subagent/background task is still running, died, finished without being integrated, or owns work that is not fully captured in the main handoff, create `agents/RESUME-<agent-name>.md` next to the handoff using `references/agent-resume-template.md`.

Do not edit files owned by a running agent. Record ownership and coordination constraints instead.

### 6. Optionally bank work

If the user explicitly requested a commit, or repo instructions require one:

- Run the relevant verification first, unless the handoff explicitly documents why verification cannot run.
- Stage only intentional files. Never `git add .` blindly.
- Commit logical chunks with messages that explain what was preserved.
- Do not push unless explicitly asked.

If you do not commit, the handoff's repo-state section must say what remains uncommitted and why.

### 7. Final response

Report only:

- Handoff document path.
- Per-agent resume document paths, if any.
- Branch and commit status.
- Validation commands run or intentionally skipped.
- One-line current state and exact next step.

## Quality bar

A cold handoff is successful when a fresh agent can answer these without reading the prior conversation:

- What is the goal?
- What is currently true?
- What changed and where?
- What evidence supports that state?
- What should I do next, exactly?
- What should I avoid redoing? (refuted leads, denied actions, upstream-impossible goals)
- How were the load-bearing findings established, so I can reproduce or extend them?
- Which PRs and issues exist, in what state, and what was deliberately not filed?
