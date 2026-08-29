# Cold-Start Handoff Template

Structure for the `NN-START-HERE.md` the next (context-free) session reads first. Fill every
section with real content. Omit a section only if truly N/A; keep the headings stable so the
format is recognizable across sessions. Adapt depth to the work (a small task needs a short doc;
a multi-day investigation needs all of it).

```markdown
# NN — START HERE (current truth, <date>)

**Single cold-start entry point. Supersedes `<prev>-START-HERE.md`.** Read top to bottom, then
the per-layer docs it links.

## 0. CRITICAL CORRECTION  (only if this session disproved an earlier premise / the goal text)
State plainly what the prior handoff or the stated goal got WRONG, and the corrected
understanding. One paragraph. This prevents the next session from re-walking a dead path.
End with: "Do not re-open <X>. It is closed."

## 1. TL;DR — where we are
- Symptom / objective in one line (+ how it's measured: the command/verdict).
- Root cause as currently understood (one line).
- Current furthest state + the single blocker that's next.
- Status flag (e.g. PASSING / BLOCKED / NO-GRAPHICS), and what's banked vs not.

## 2. THE JOURNEY — the cascade (so the next session never re-walks it)
A table: each layer/attempt → verdict (FIXED / REFUTED / PHANTOM / MISREAD / OPEN) → which doc.
| # | Layer / hypothesis | Verdict | Doc |

## 3. WHAT IS FIXED & BANKED
Numbered list. For each: the file(s), what changed, why it's correct (one line), the doc.
Note which are committed (and on which branch) vs intentionally uncommitted.

## 4. WHAT IS STAGED / GATED  (env flags, feature gates, branches)
Every flag/gate the next session must know: name, where (recompile-time vs runtime), what it
turns on, and the exact command to reproduce the current state with it.

## 5. THE EXACT NEXT STEP
The single most important section. The precise next action: the bug/gate, the evidence
(addresses, values, same-snapshot diffs), the method to attack it, the suspected layer, and
ready-made probes/commands. Include an anti-cascade note: when to STOP and hand off again.

## 6. DEBUGGING METHODOLOGY THAT WORKED
The techniques that produced progress (e.g. oracle/differential, clean-room gating to remove
masking, anti-cascade "question the architecture" after N layers, measurement discipline — how
to tell a real bug from a phantom). Reusable for the next bug.

## 7. TOOLING ALREADY SET UP (reuse — don't rebuild)
Each tool: where it is, how to invoke it, key flags, gotchas (e.g. analyzer harness, emulator/
oracle + its quirks, test/verify harness, debug ports). Exact paths and commands.

## 8. DON'T RE-CHASE (refuted leads + evidence)
Bulleted list of dead ends with one-line evidence each, so they're not re-investigated.

## 9. REPO / BUILD / COMMIT STATE
- Branch + recent commit hashes (what each commit holds).
- What's git-ignored / generated (regenerate how).
- Exact build / run / test / verify commands.
- What's intentionally uncommitted and why.
- To resume: the literal sequence of commands to get back to the current state.

## 10. RUNNING AGENTS  (if any were active or recently finished)
For each: name, what it was doing, its status (running / done / died), and a link to its
`agents/RESUME-<name>.md`. The resume docs hold the detail.

## 11. SUCCESS BAR
The exact, measurable definition of done (the command + the output that means success).
```

Notes:
- Prefer relative links between docs.
- If the doc would exceed ~500 lines, split detail into per-layer docs and keep this as the index.
- "Current truth" means: if an earlier doc and this one disagree, this one wins — say so.
