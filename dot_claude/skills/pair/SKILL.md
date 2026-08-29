---
name: pair
description: Enter tier-1 pair mode — work inline with the user instead of delegating to subagents. Use when the user invokes "/pair", says "pair with me", "let's pair on", or asks to pair-program through a change together.
---

# Pair Mode

Work WITH the user in the main context. For the duration of the session this overrides the
Agent Delegation rules in CLAUDE.md and the agent-team-orchestrator skill.

Pair mode works even outside TIER1 paths: explicit invocation = explicit intent.

## Protocol

1. Do NOT delegate — state "TIER1 path — pair mode" (or "pair mode — user invoked") and why.
2. Propose exactly 2 approaches with one-line tradeoffs; WAIT for the user's pick. Do not
   start implementing before they choose.
3. Implement in the main context, narrating non-obvious decisions as they're made.
4. Before declaring done, ask the user ONE specific why-question about the diff and wait
   for the answer.

## Session scope

- The session stays in pair mode until the user says stop.
- On TIER1 paths, bypass only by the user editing the repo's `TIER1.md` — never silently.
