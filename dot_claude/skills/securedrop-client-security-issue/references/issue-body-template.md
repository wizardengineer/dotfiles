# Issue body template

Fill in the placeholders. Keep the title line + these five `##` sections, in order.
Do NOT add a "Severity:" line — severity lives in labels only.

```markdown
# <concise title describing the flaw/behavior, NOT the fix>

## Vulnerability

<1-2 paragraphs: what the code does wrong, the precise mechanism, and the
trust/threat boundary it crosses. Name the concrete function(s) involved.>

<Optional for complex issues: a numbered step sequence of the mechanism, e.g.>
<1. `<function_a>` does X without validating Y.>
<2. `<function_b>` then consumes the unvalidated result and Z.>

<Optional Duplicate Check: "This is a distinct <mechanism> variant. It differs
from #<n>, which covers <sibling mechanism>. A fix for #<n> ... does not cover
this path because <reason>.">

## Impact

<1 short paragraph: what an attacker / compromised component achieves. Scoped and
honest. Explicitly disclaim over-claims when relevant, e.g. "This does not claim
plaintext exfiltration or remote code execution.">

## Affected Code

`path/to/file.ext`
<optionally a second `path/to/other.ext`>

- `path/to/file.ext:<start>-<end>` — <what this range does wrong>
- `path/to/file.ext:<start>-<end>` — <what this range does wrong>

<OR a short prose form:>
<Relevant code: `<function>()` at `path/to/file.ext:<line>` <what it does wrong>.>

## Proof of Concept

See the follow-up PoC comment for a self-contained reproducer. <one sentence
describing what the PoC does>.

Relevant output:

```text
- <short-slug>: Confirmed: <key=value; key=value; ...> vulnerable=true.
```

## Suggested Fix

<1 paragraph or short list of concrete remediation options, ordered from
most-robust to acceptable-alternative.>
- <most robust option>
- <acceptable alternative>
```

Notes:
- The `Relevant output:` block MUST match the PoC comment's `Expected result
  summary:` verbatim in its confirmation fields.
- Use ```json instead of ```text only if the confirmed result is naturally JSON.
