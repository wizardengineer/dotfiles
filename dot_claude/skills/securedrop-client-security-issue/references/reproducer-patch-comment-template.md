# Reproducer Patch comment template

Use when the proof is a patch that adds real tests (server-backed E2E + focused
unit) rather than a standalone script. Post this as the single proof comment.
`<slug>` matches the artifact filename `<slug>-poc.patch`.

```markdown
## Reproducer Patch

This is the self-contained proof patch used for the server-backed E2E and focused
unit reproducer described in the issue body. <one sentence on what the tests prove>.

Checksum:

```text
<sha256>  <slug>-poc.patch
```

Apply from the root of a clean `securedrop-client` checkout:

```bash
git apply <slug>-poc.patch
```

Run the server-backed E2E proof:

```bash
cd app
PROXY_ORIGIN=http://127.0.0.1:8181/ \
SERVER_PORT_OFFSET=100 SERVER_READY_TIMEOUT_MS=1800000 \
  node ./node_modules/vitest/vitest.mjs run \
  --config vitest.config.ts --project=server --no-file-parallelism \
  server_tests/<slug>-e2e.test.ts
```

Run the focused unit proof:

```bash
cd app
node ./node_modules/vitest/vitest.mjs run \
  --config vitest.config.ts --project=unit \
  src/<path>/<slug>.test.ts
```

Patch:

```diff
diff --git a/app/<path>/<file> b/app/<path>/<file>
index <old>..<new> <mode>
--- a/app/<path>/<file>
+++ b/app/<path>/<file>
@@ ... @@
+<added test / setup lines>
```
```

Rules:
- `Checksum:` is a ```text block: `<sha256>  <slug>-poc.patch` (two spaces).
- Apply with `git apply <slug>-poc.patch` from the checkout root.
- Run commands use portable `node` / `python3` with env vars inline — never
  machine-specific interpreter paths.
- Repo-relative paths only; no private/local paths (`/Users/...`, `/tmp/...`, etc.).
- The embedded `diff` is the complete unified diff of the reproducer patch.
