---
name: securedrop-client-pr
description: Use when opening or writing a pull request for securedrop-client (freedomofpress/securedrop-client) — drafts the title, description sections, test plan, and checklist in the project's conventional style. Triggers on requests like "write a PR for securedrop-client", "draft the PR description", "open a pull request against securedrop-client", "format my securedrop PR", or "add a test plan and checklist to this PR". Produces a Conventional-Commit title and a Summary → Context → Test plan → Notes → Checklist body that keeps the upstream repo's Test plan and Checklist verbatim.
---

# securedrop-client-pr

Author pull requests for **freedomofpress/securedrop-client** in the house style: a
Conventional-Commit title and a body that layers `## Summary`, `## Context`, and
`## Notes` on top of the upstream PR template's `## Test plan` and `## Checklist`.

## 1. When to use

Use this when you are opening, writing, or revising a pull request against
`freedomofpress/securedrop-client` and want the title, body, test plan, and checklist to
match the project's conventional style. Also use it to convert a rough change description
into a ready-to-submit PR body.

## 2. Title convention

Conventional Commit: `type(scope): imperative summary`.

- **type** ∈ `fix`, `feat`, `refactor`, `docs`, `test`, `chore`.
- **scope** = the affected component (e.g. `database`, `export`, `gui`, `proxy`, `readme`).
- **summary** = imperative mood, lowercase, no trailing period, describes the *effect*.
- Aim for ~60–90 characters.

Example: `fix(database): enforce source key immutability after TOFU initial write`

## 3. Body structure (in order)

Write these headings in exactly this order. Keep the `## Test plan` and
`## Checklist` sections from the upstream template verbatim, and enrich the rest.

### `## Summary`
A short bulleted list of what the change does (typically 3 bullets). Describe behavior and
effect, not a code walkthrough.

### `## Context`
Link the motivating issue with a **non-closing** reference so a draft does not auto-close:

```
Refs https://github.com/freedomofpress/securedrop-client/issues/<N>.
```

Follow with one sentence tying the change to prior art — an existing pattern or a precedent
PR ("follows the same pattern used in #3173") as design justification.

### `## Test plan`
One or more fenced ` ```sh ` blocks with **exact, copy-pasteable** commands, scoped to the
files/tests you touched (not a blanket `make test`). Include a formatter/lint check and
`git diff --check`. For a ready (non-draft) PR, **paste the observed passing output** as
evidence — pytest counts (`32 passed`), `ruff check` → `All checks passed!`, etc.

```sh
pytest tests/path/to/test_touched.py
ruff check .
ruff format --check .
git diff --check
```

### `## Notes`
Optional. State deliberate scope boundaries and deferrals ("this does NOT yet do X
because…"), or stacked-PR dependencies. Delete the heading if there is nothing to say.

### `## Checklist`
Keep the upstream template's checklist **verbatim**, including the link references. Never
delete it. Tick a box only when that item is genuinely done; leave it unchecked (and say
where you need support) otherwise.

## 4. Issue-linking rules

- While a PR is a **draft** or should not auto-close, use `Refs <full issue URL>.` under
  `## Context`. This references without closing.
- Use `Closes #N` / `Fixes #N` **only** when merging the PR should auto-close the issue.
  Avoid it on drafts.
- Cite precedent PRs (`follows the same pattern used in #<N>`) as design justification.

## 5. Commit convention

- One focused commit per PR.
- Subject: imperative, **Capitalized**, no trailing period
  (e.g. `Enforce source key TOFU in database`).
- Commit body optional; the Conventional-Commit `type(scope):` prefix is a **PR-title**
  rule and is optional on the commit subject.
- No sign-off and no `Co-Authored-By`/trailers unless the repo explicitly requires them.

## 6. Rules

1. **Title** = Conventional Commit `type(scope): imperative summary`, lowercase, no period; types fix/feat/refactor/docs/test/chore.
2. **Body order**: Summary → Context → Test plan → Notes → Checklist.
3. Keep the repo's `## Test plan` and `## Checklist` **verbatim** (including link refs); never delete the checklist; tick boxes only when genuinely done.
4. **Link issues** with `Refs <full issue URL>` under `## Context`; use `Fixes #N`/`Closes #N` only when the PR should auto-close on merge (avoid on drafts).
5. **Test plan** = exact reproducible commands in fenced ` ```sh ` blocks, scoped to the touched files/tests, including `git diff --check`; paste passing output on non-draft PRs.
6. **Commits**: one focused commit; subject imperative + Capitalized, no trailing period; body optional; no trailers unless required.
7. Use `## Notes` to state deliberate scope boundaries and deferrals.
8. Frame everything on upstream `freedomofpress/securedrop-client`; never name a fork.

## 7. Reference

A ready-to-fill body skeleton with inline placeholder guidance lives in
[references/pr-template.md](references/pr-template.md). Copy it, fill the placeholders, and
delete `## Notes` if unused.
