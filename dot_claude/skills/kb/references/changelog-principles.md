# Changelog Principles

Why entries are structured the way they are.

## Token Budget

Session entries target **400-800 tokens**. Industry consensus (Anthropic, Factory.ai, Manus): handoff summaries should be 500-1500 tokens. We aim for the lower end because:
- Multiple entries accumulate across sessions
- CLAUDE.md already holds permanent context
- Lean entries get read fully; long entries get skimmed

## Anti-Duplication Rule

**Never repeat CLAUDE.md content in a changelog entry.** Use pointer references:
```
See CLAUDE.md § macOS Constraints for full table.
```
CLAUDE.md = what's always true. Changelog = what happened THIS session.

## Progressive Disclosure (Three Levels)

1. **`kb status`** (~80 tokens) — counts + latest session title. Agent reads this first.
2. **Session entry** (~500 tokens) — what happened, decisions, next steps. Agent reads if relevant.
3. **Individual bug/decision/dead-end files** (~200 tokens each) — full detail. Agent reads on demand.

The agent never reads everything. It reads level 1, decides if level 2 is needed, drills to level 3 only for specific topics.

## Dead-Ends Are the Highest-Value Category

Every dead-end documented saves 10-30 minutes of a future session retrying it. Include:
- **What was tried** (specific enough to recognize)
- **Why it failed** (the actual error or conceptual flaw)
- **What's needed instead** (if known)

## Cold Start Instructions

Every session entry ends with a blockquote containing ONE instruction:
```markdown
> **Cold start:** Create `Source/Darwin/Tests/ASMTestRunner.h` — config parser for loading .bin + .config.bin test files.
```
The next session reads this and starts working in under 60 seconds. No ambiguity, one action, one file path.

## Adversarial Verification for Decisions

Important decisions use two-agent debate:
1. **Prover** argues FOR the approach with evidence
2. **Breaker** argues AGAINST, finding weaknesses
3. **Synthesis** merges what survived

Document in the decision entry:
```yaml
method: adversarial-verification
```
And in the body: what claims survived, what was broken, what was revised.

## Append-Only + Archival

- Never edit previous session entries (mirrors ADR immutability)
- When `sessions/` exceeds 5 entries, move older ones to `sessions/archive/`
- Keep latest 3-5 in active directory
- Memory file always points to latest
