# Patch comment template

Post this once a fix exists. It ties the fix back to the PoC result and shows a
collapsible diff preview. `<slug>` matches the PoC artifact slug.

```markdown
# Patch

`<slug>.patch`

Verification: the original PoC now returns result=not_confirmed under
<runtime, e.g. Python 3.11.13>; <state that the new guard fires and the vulnerable
outcome no longer occurs, e.g. "the traversal manifest overwrite case now raises
RuntimeError: Unsafe archive path and no malicious module is copied.">

<details>
<summary>Preview</summary>

```diff
diff --git a/path/to/file.ext b/path/to/file.ext
index <old>..<new> <mode>
--- a/path/to/file.ext
+++ b/path/to/file.ext
@@ ... @@
-<removed line>
+<added line>
```
</details>
```

Rules:
- First line names the patch: `# Patch` then the `<slug>.patch` filename (or a link
  to the attachment).
- `Verification:` states that re-running the PoC now yields not_confirmed / the guard
  now fires — tie it directly to the PoC's confirmation fields.
- Wrap the unified diff in `<details><summary>Preview</summary>` … `</details>` with
  a blank line before the ```diff fence.
- Repo-relative paths only; no private/local/absolute machine paths.
