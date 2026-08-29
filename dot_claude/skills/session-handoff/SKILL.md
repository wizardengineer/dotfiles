---
name: session-handoff
description: >-
  Produce a complete, self-contained handoff so the NEXT session (which will have
  zero prior context) can resume cold. Use when wrapping up or pausing a session,
  when the user says "create a handoff", "hand off to the next session", "wrap up",
  "pause work", "save progress for next time", "we have to create a strong handoff",
  when context is running low, or before ending a long/multi-agent investigation.
  Writes a cold-start handoff doc (what happened, root cause, debugging methods,
  changes, prior context, exact next step), commits the uncommitted work that should
  be preserved, and — for every background/subagent still running or recently
  finished — records where it left off in its own resume markdown so it can continue.
---

# Session Handoff

Goal: leave the repo and docs so a fresh session with **no memory of this one** can pick up
exactly where things stand, and any running agents can resume. Three deliverables:
(1) a cold-start handoff doc, (2) committed work, (3) a resume markdown per running agent.

Default to **high fidelity over brevity** in the handoff itself — the next session has nothing
else. But keep it *accurate*: explicitly correct any earlier premise this session disproved.

## Workflow

Do these in order. Steps 1–2 gather; 3 commits; 4–5 write docs; 6 reports.

### 1. Determine the handoff location and the "current truth"

- Find where handoffs live: check for `.planning/handoff/`, `docs/handoff/`, `HANDOFF.md`, a
  `STATE.md`/`STATUS.md` with a resume pointer, or prior `NN-START-HERE.md` files. If none exists,
  create `handoff/` at repo root (ask the user only if genuinely ambiguous).
- Identify the prior cold-start doc (highest-numbered `START-HERE` or the resume-pointer target).
  The new doc **supersedes** it; pick the next number/name (e.g. `NN-START-HERE.md`).
- Assemble the "current truth": original goal, what was tried, what is now known, what is fixed,
  the current furthest state/blocker, and the exact next step.

### 2. Inventory uncommitted work and running agents

- `git status --short` + `git diff --stat` — modified/untracked files. Note generated/ignored
  paths (`git check-ignore <dir>`) so you don't try to commit them.
- `git branch --show-current` + `git log --oneline -5` — current branch + recent history.
- List every background/subagent **still running OR completed-but-not-yet-banked** this session:
  name/id, task, the files/area it owns, and last reported state (final return message, or "still
  running — last known progress"). Needed for steps 4–5. (Do NOT edit files a running agent owns.)

### 3. Commit what should be preserved

Follow the project's git conventions (check CLAUDE.md / AGENTS.md). General procedure:

- **Verify green BEFORE committing**: run the project's build + tests; commit only if they pass
  (or failures are pre-existing and noted). Never silently commit known-broken state.
- **Branch first if on the default branch** (`main`/`master`) unless the project clearly commits
  session work directly to it. Use a descriptive branch name.
- **Commit in logical groups** (e.g. core fixes / runtime / docs) with messages stating what
  changed and why; reference the handoff doc. Do NOT `git add .` blindly — skip generated/ignored
  dirs and stray temp files.
- **Do NOT push** unless the user explicitly asked. Apply any required commit trailer (e.g.
  `Co-Authored-By`) per the project's instructions.
- If something is intentionally NOT committed (diagnostics, gated experiments, WIP), say so in the
  handoff's repo-state section with the reason.

### 4. Write the cold-start handoff doc

Create the new `NN-START-HERE.md`. It must stand alone. Use
`references/cold-start-handoff-template.md` for the section-by-section structure; fill every
section with real content (no placeholders). Most important section in a long investigation:

- **Critical correction** (when applicable): if this session disproved/superseded an earlier
  handoff's premise or the stated goal, say so **loudly at the very top** so the next session
  doesn't re-walk a dead path.

### 5. Write a resume markdown per running agent

For EACH agent from step 2 that was running (or whose work isn't fully folded into the main
handoff), create a separate file `agents/RESUME-<agent-name>.md` using
`references/agent-resume-template.md`. Each must let that agent (or a fresh one) continue with
zero context: its mission, exactly where it left off, what it found/changed, the precise next
action, the files/addresses/commands it used, and the hard rules it operated under.

- If a background agent is still running at handoff time, note that explicitly and capture its
  last-known progress — the resume doc is the recovery path if it dies (e.g. a server error).
- In the main handoff, add a short "Running agents" subsection listing each agent + its resume doc.

### 6. Update the resume pointer and report

- Point the project's resume pointer (`STATE.md`/`STATUS.md` top, or a README line) at the new
  `NN-START-HERE.md`. Keep prior pointers as "superseded" if useful for forensics.
- Tell the user concisely: the handoff doc path, the branch + what was committed (hashes), the
  per-agent resume docs, and the one-line current state + next step.

## Principles

- **Self-contained**: assume the reader has only the docs you wrote. Spell out addresses, paths,
  exact commands, env flags. Link related docs by relative path.
- **Faithful, not optimistic**: report the real furthest state and what's NOT done. Correct
  superseded premises explicitly. Describe symptoms precisely ("garbage that differs every run" ≠
  "deterministic bug").
- **Banked = committed, or clearly documented as intentionally-uncommitted.** Nothing important
  should live only in volatile context.
- **One entry point**: a single obvious "read this first" doc, and a single resume pointer to it.
