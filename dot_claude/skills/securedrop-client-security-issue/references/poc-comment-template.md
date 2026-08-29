# PoC comment template

The proof for a script-based vulnerability. Post this as one follow-up comment.
`<slug>` is a short kebab-case identifier reused for the artifact filename.

```markdown
## Proof of Concept

Save the script below as `<slug>-poc.py` in a checkout that has `securedrop-client`
available, then run:

```bash
python3 -B <slug>-poc.py /path/to/securedrop-client
```

Expected result summary:

```text
Confirmed: <key=value>, <key=value>, ... and <key=value>. vulnerable=true
```

PoC source:

```python
#!/usr/bin/env python3
"""<one-line description of what this reproducer proves>."""

from __future__ import annotations

import sys
from pathlib import Path


def main() -> int:
    """Load the real target from the checkout and print the confirmation summary.

    Returns:
        Process exit code (0 on success).
    """
    if len(sys.argv) != 2:
        print("usage: <slug>-poc.py /path/to/securedrop-client", file=sys.stderr)
        return 2
    repo = Path(sys.argv[1]).resolve()

    # Import / load the REAL target module or schema by path from the checkout.
    # e.g. sys.path.insert(0, str(repo / "client")) then import the module,
    # or read the real schema/source file under `repo` — never copy code here.

    # ... exercise the vulnerable code path against the real target ...

    # Emit a summary whose fields match the body's `Relevant output:` block and
    # end with vulnerable=true (or result=confirmed).
    print("Confirmed: <key=value>, <key=value>. vulnerable=true")
    return 0


raise SystemExit(main())
```
```

Rules:
- The `Expected result summary:` MUST match the issue body's `Relevant output:`.
- The script is fully self-contained, takes the repo path as `argv[1]`, loads the
  real target by path, and ends with `raise SystemExit(main())`.
- Only `/path/to/securedrop-client` and repo-relative paths — no private/local paths.
