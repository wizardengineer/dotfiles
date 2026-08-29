<!--
PR body skeleton for freedomofpress/securedrop-client.
Fill each placeholder, then delete these comment blocks and the ## Notes section if unused.
Title (set separately): type(scope): imperative summary   e.g. fix(database): enforce ...
-->

## Summary

- <what the change does — bullet 1, describe effect not code>
- <bullet 2>
- <bullet 3>

## Context

Refs https://github.com/freedomofpress/securedrop-client/issues/<N>.
<!-- Use `Refs <url>` for a draft / non-closing PR. Use `Closes #<N>` ONLY when merging
     should auto-close the issue. -->
<One sentence tying this to prior art — an existing pattern or precedent PR, e.g. "follows the same pattern used in #<N>".>

## Test plan

<!-- Exact, copy-pasteable commands scoped to the files/tests you touched. Include a
     formatter/lint check and `git diff --check`. On a ready (non-draft) PR, paste the
     observed passing output (pytest counts, `All checks passed!`) below each block. -->

```sh
pytest tests/path/to/test_touched.py
ruff check .
ruff format --check .
git diff --check
```

## Notes

<!-- Optional: deliberate scope boundaries, what was deferred and why, stacked-PR deps.
     Delete this whole section if there is nothing to add. -->

## Checklist

<!-- If you leave any box below unchecked, please clarify where you may need support.
     If you're unsure, that's fine — a reviewer can help you out. -->

This change accounts for:
- [ ] testing changes on Qubes as needed (especially changes related to cryptography, export, disposable VM use, or complex UI changes)
- [ ] any needed updates to the [AppArmor profile] for files beyond the application code
- [ ] any needed [self-contained] database migrations (including testing against a clean test database from `main`)

[AppArmor profile]: https://github.com/freedomofpress/securedrop-client/blob/main/proxy/usr.bin.securedrop-proxy
[self-contained]: https://github.com/freedomofpress/securedrop-client/blob/main/app/README.md#database
