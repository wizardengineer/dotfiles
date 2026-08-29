# Entry Format Templates

Copy-paste these YAML front matter templates when creating new entries.

## Session Entry

File: `docs/project-history/sessions/NNN-slug.md`

```yaml
---
id: "NNN"
title: "One-line summary"
date: YYYY-MM-DD
status: complete | in-progress
tags: [topic1, topic2]
commits: "abc1234..def5678"
commit_count: N
---
```

Body (≤500 tokens):
```markdown
# Session NNN — Title

**Status:** 2-3 sentences.

## Completed
- [x] Thing with `file/path.cpp`
- **Verification:** how we proved it

## Decisions Made
- **DEC-NNN title** — See `decisions/DEC-NNN-slug.md`

## Next Steps
1. **IMMEDIATE:** exact action with file path
2. Second priority

> **Cold start:** One sentence. One action. One file path.

## Documents
| Doc | Path | Why |
|-----|------|-----|
| Plan | `docs/superpowers/plans/...` | Context for next task |
```

## Decision Entry

File: `docs/project-history/decisions/DEC-NNN-slug.md`

```yaml
---
id: "DEC-NNN"
title: "What was decided"
date: YYYY-MM-DD
status: accepted | superseded
tags: [topic1]
session: "NNN"
method: adversarial-verification | testing | discussion
---
```

Body:
```markdown
# DEC-NNN: Title

**Decision:** What we chose.

**Why:** Rationale in 2-3 sentences.

**Rejected:** What was considered and dropped, with why.

**Consequences:** What this means going forward.

**Verification method:** (if adversarial) What the prover argued, what the breaker argued, what survived.
```

## Bug Entry

File: `docs/project-history/bugs/BUG-NNN-slug.md`

```yaml
---
id: "BUG-NNN"
title: "Bug title"
date: YYYY-MM-DD
status: fixed | open | wontfix
tags: [platform, component]
session: "NNN"
severity: critical | high | medium | low
commit: "hash"
---
```

Body:
```markdown
# BUG-NNN: Title

**Root cause:** Why it happened.

**Impact:** What broke (exit code, error message).

**Fix:** What was changed.

**Files:** `path/to/file.cpp:line`
```

## Dead-End Entry

File: `docs/project-history/dead-ends/slug.md`

```yaml
---
title: "What was tried"
date: YYYY-MM-DD
reason: "One-line why it failed"
tags: [topic]
session: "NNN"
---
```

Body:
```markdown
# Dead End: Title

**What was tried:** Description of the approach.

**Why it failed:** Specific error or conceptual flaw.

**What's needed instead:** Alternative approach (if known).
```

## Constraint Entry

File: `docs/project-history/constraints/slug.md`

```yaml
---
title: "Constraint category"
tags: [platform, topic]
---
```

Body: bullet list of environmental facts discovered.
