---
name: securedrop-client-security-issue
description: Use when filing a security vulnerability issue for securedrop-client, or when writing its follow-up Proof-of-Concept, patch, or reproducer-patch comments — enforces the 5-section body, label taxonomy, portable reproducers, and path scrubbing.
---

# SecureDrop Client Security Issue

Author a SecureDrop Client security-vulnerability issue and its follow-up comments
in the established house style: a fixed 5-section body, severity carried only by
labels, and self-contained portable reproducers.

## 1. When to use

Use this skill when any of the following applies to the upstream **securedrop-client**
security issue tracker:

- Filing a new security-vulnerability issue.
- Writing the follow-up **Proof of Concept** comment (standalone script proof).
- Writing the **Patch** comment once a fix exists.
- Writing the **Reproducer Patch** comment (test-patch proof: E2E + unit).

If you are triaging or writing a non-security bug, this style does not apply.

## 2. Issue body template

Use exactly these sections, in this order (title line + five `##` sections). See
`references/issue-body-template.md` for the fill-in skeleton.

1. `# <title>` — concise, declarative, describes the **flaw/behavior, NOT the fix**.
   Good: "better-sqlite3 archives are extracted before checksum verification".
   Good: "Print job-send errors are reported as successful print workflows".
2. `## Vulnerability` — 1-2 paragraphs: what the code does wrong, the precise
   mechanism, and the **trust/threat boundary** it crosses. Name the concrete
   function(s) involved. For complex issues, expand into a numbered step sequence
   and add a Duplicate Check paragraph (see §5).
3. `## Impact` — 1 short paragraph: what the attacker / compromised component
   achieves. Keep it **scoped and honest**; explicitly disclaim over-claims when
   relevant (e.g. "does not claim plaintext exfiltration or remote code execution").
4. `## Affected Code` — the file path(s), then a bullet list of `path:line-range`
   anchors OR a short "Relevant code:" prose list naming the exact functions and
   what each does wrong. **Repo-relative paths only.**
5. `## Proof of Concept` — a **STUB**: "See the follow-up PoC comment for a
   self-contained reproducer." plus one sentence describing what the PoC does, then
   a short `Relevant output:` fenced block (usually ```text). Never inline the
   script in the body.
6. `## Suggested Fix` — 1 paragraph or short list of concrete remediation options,
   ordered most-robust to acceptable-alternative.

**Never** write "Severity:" or any severity text in the body. Severity and
classification live entirely in GitHub labels (§3).

## 3. Label taxonomy

Severity and metadata are expressed **only** as labels. Every security issue carries:

- `security :warning:` (always)
- `bug :bug:` (always)
- exactly one `priority:high` | `priority:medium` | `priority:low`
- one language tag: `python` or `javascript`

Add when relevant: `component:*` (e.g. `component:CI/CD :robot:`) and/or
`dependencies` (build/CI/supply-chain issues).

Priority maps to informal severity:

- `priority:high` — supply-chain / verification bypass.
- `priority:medium` — integrity / data-completeness.
- `priority:low` — retry loops, mis-reported status.

## 4. Follow-up comment types

Post **exactly one** proof comment — a PoC comment (script proof) OR a Reproducer
Patch comment (test-patch proof) — and add a Patch comment once a fix lands.

- **PoC comment** — `references/poc-comment-template.md`. Use when the proof is a
  standalone Python script that loads the real target by path and prints a
  confirmation summary.
- **Patch comment** — `references/patch-comment-template.md`. Use once a fix exists:
  `# Patch` + `Verification:` (PoC now returns not_confirmed) + collapsible
  `<details>Preview</details>` diff.
- **Reproducer Patch comment** — `references/reproducer-patch-comment-template.md`.
  Use when the proof is a patch adding real tests (E2E + unit) rather than a script:
  `## Reproducer Patch` + sha256 checksum + `git apply` + run commands + embedded diff.

## 5. Scrubbing & consistency rules

- **Repo path placeholder**: always `/path/to/securedrop-client` as the argv target.
  Never a real local path.
- **Portable tools**: `python3`, `node`, `git apply` — never machine-specific
  interpreter paths (`/opt/homebrew/...`, `/usr/local/bin/...`).
- **No private/local paths**: never leak `/Users/...`, `/private/var/...`, `/tmp/...`,
  `pocs/...`, or any note-dir / working-tree path. Reproducers reference only
  repo-relative paths and the placeholder root.
- **Self-contained artifacts**: PoC scripts and patches carry everything needed and
  load the real target module/schema by path rather than copying code.
- **Runtime scoping honesty**: when a result depends on runtime version, state it
  (e.g. "supported Python 3.11+ before 3.14 hardening").
- **Result-summary discipline**: the body's `Relevant output:` MUST match the
  comment's `Expected result summary:`, using `key=value` fields that end in
  `vulnerable=true` / `result=confirmed`.
- **Duplicate Check**: before filing, search the tracker; if a sibling issue exists,
  cite it inside `## Vulnerability` as related-but-distinct using plain `#<n>` and
  explain why a fix for the sibling does NOT cover this path.
- **No hidden tracking markers**: never add hidden HTML comment markers to any
  issue or comment.

## Rules

1. Body has exactly the title line + 5 `##` sections in order: Vulnerability,
   Impact, Affected Code, Proof of Concept, Suggested Fix.
2. Title describes the flaw/behavior, never the fix.
3. Never write "Severity:" or any severity text in the body — labels only.
4. Labels: always `security :warning:` + `bug :bug:` + one `priority:*` + a language
   tag; add `component:*` / `dependencies` when relevant.
5. `## Affected Code` uses `path:line-range` anchors or a function-level list;
   repo-relative paths only.
6. `## Proof of Concept` in the body is a stub + short `Relevant output:` block that
   matches the comment's `Expected result summary:` and ends in `vulnerable=true` /
   `result=confirmed`.
7. `## Impact` is scoped and honest; disclaim over-claims when relevant.
8. Post one proof comment (PoC or Reproducer Patch); add a Patch comment once fixed.
9. All reproducers use `/path/to/securedrop-client`, portable `python3`/`node`/
   `git apply`, no private/absolute machine paths, and are self-contained.
10. Name artifacts `<slug>-poc.py` / `<slug>-poc.patch` consistently; reproducer
    patches include a sha256 checksum + `git apply` + run commands + embedded diff.
11. Do a Duplicate Check; cite related-but-distinct issues by `#<n>` and explain why
    their fixes don't cover this one.
12. No hidden tracking markers anywhere.
