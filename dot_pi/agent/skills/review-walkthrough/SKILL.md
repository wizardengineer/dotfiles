---
name: review-walkthrough
description: Generates an interactive HTML walkthrough for reviewing code changes. Shows the final diff split into logical, ordered chunks with explanations and a critical code review. Use when the user wants to review changes, create a code review walkthrough, or visualize a branch or PR as a guided tour.
argument-hint: "[optional branch | ref | commit range]"
compatibility: Requires git, gh, python3, and a local browser opener such as `open` on macOS.
---

# Review Walkthrough

Generate a self-contained HTML file that walks a reviewer through code changes step by step, with diffs on the left and a tabbed right pane containing explanations and a critical review.

This is adapted for Pi from Trail of Bits' internal `review-walkthrough` skill concept (PR #335).

The reviewer should see the **final state** of the changes, split into logical chunks that you determine. Commits are usually irrelevant; optimize grouping and ordering for comprehension.

## When to Use

- Walking a reviewer through code changes step by step
- Creating a visual code review walkthrough for a PR or branch
- Splitting a large diff into logical, ordered chunks with explanations
- Accepting, rejecting, or editing LLM-generated review comments before submitting them to a PR

## When NOT to Use

- For simple diffs that do not need guided explanation
- When a plain `git diff` is enough
- For automated CI review checks
- When the user wants you to directly review code in chat instead of producing an artifact

## Invocation

Typical Pi usage:

```text
/skill:review-walkthrough
/skill:review-walkthrough feat/my-branch
/skill:review-walkthrough HEAD~5..HEAD
```

Natural-language requests should also load this skill.

If the skill was invoked with `/skill:review-walkthrough ...`, Pi appends the arguments as a trailing `User: ...` line. Treat that as the optional review target.

## High-Level Flow

1. Determine the review target and base branch
2. Get the full diff and changed file list
3. Read the changed files and understand the whole change
4. Split the diff into logical review steps
5. Write an explanation and a critical review for each step
6. Generate a self-contained HTML file from [template.html](template.html)
7. Open it in the browser and report the output path

## Step 1: Determine the review target and base branch

Default to the current branch if the user does not specify a target.

### Supported targets

Prefer these interpretations, in order:

1. **Explicit commit range** like `HEAD~5..HEAD` or `main...HEAD`
2. **Explicit branch/ref** like `feat/my-branch`
3. **Current branch** when nothing explicit was supplied

### Base branch detection

If the effective target is the current branch or another branch/ref, first try to detect the PR base branch via `gh pr view`. If that fails, fall back to `main`.

```bash
# current branch PR base if present
gh pr view --json baseRefName -q '.baseRefName' 2>/dev/null
```

If that is empty, use `main`.

When working from a named branch/ref rather than `HEAD`, prefer this pattern:

```bash
BASE_BRANCH="<detected-or-main>"
MERGE_BASE=$(git merge-base <target-ref> origin/$BASE_BRANCH)
git diff "$MERGE_BASE"..<target-ref>
```

When working from the current branch:

```bash
BASE_BRANCH="<detected-or-main>"
MERGE_BASE=$(git merge-base HEAD origin/$BASE_BRANCH)
git diff "$MERGE_BASE"..HEAD
```

When working from an explicit commit range, use the user-provided range directly for `git diff` and `git diff --name-only`.

### File list

Always also collect the changed file list:

```bash
git diff --name-only <same-range-used-for-the-diff>
```

### Detect PR metadata for inline commenting

If the current branch has an open PR, collect metadata so the HTML can generate `gh api` review-comment commands.

```bash
gh pr view --json number -q '.number'
gh pr view --json headRefOid -q '.headRefOid'
gh repo view --json owner -q '.owner.login'
gh repo view --json name -q '.name'
```

Build:

```python
pr_meta = None
try:
    pr_number = run("gh pr view --json number -q '.number'")
    if pr_number.strip():
        head_sha = run("gh pr view --json headRefOid -q '.headRefOid'").strip()
        owner = run("gh repo view --json owner -q '.owner.login'").strip()
        repo = run("gh repo view --json name -q '.name'").strip()
        pr_meta = {
            "owner": owner,
            "repo": repo,
            "pr_number": int(pr_number),
            "head_sha": head_sha,
        }
except Exception:
    pass
```

If there is no PR, use `null` in the template.

## Step 2: Read and understand all changes

Read every changed file. Understand the feature or refactor as a whole before splitting it.

Use conversation context when available. If you just helped implement the change, reuse that architectural understanding.

## Step 3: Split into logical review steps

This is the core intellectual work. Group the full diff into **ordered chunks** that a reviewer should read sequentially.

Each step should:

- Be self-contained enough to understand on its own
- Build on previous steps
- Cover a single concept

### Ordering principles

1. Data models and schemas first
2. Configuration and wiring second
3. Core logic and services third
4. Integration points fourth
5. API or UI surfaces fifth
6. Tests and cleanup last

### Grouping principles

- Group a file with its test if both are small and tightly coupled
- Separate large files into their own step even if related
- Merge tiny infrastructure changes into adjacent steps
- Do not create steps for 1-2 trivial lines unless they matter conceptually

For each step, define:

- `title`
- `files`
- `diff`
- `explanation`
- `review`

## Step 4: Write explanations

For each step, write a concise HTML explanation covering:

- **What** this chunk does
- **Why** it exists
- **Key design decisions** or trade-offs
- **How it connects** to nearby steps

Use HTML fragments like:

```python
explanations = [
    '<p>This is the <strong>foundation</strong>...</p><ul><li>Point 1</li></ul>',
    '<p>Extends the service to support...</p>',
]
```

Aim for roughly 50-150 words per step. Use `<strong>` for key ideas and `<code>` for identifiers.

## Step 5: Write critical reviews

For each step, write a critical PR-style review. Look for:

- Bugs and logic errors
- Security issues
- Missing validation
- API design problems
- Performance concerns
- Edge cases or poor failure handling

Each review item is a JSON object with:

- `severity`: `high`, `medium`, or `low`
- `title`
- `body`
- optional `file`
- optional `line`
- optional `end_line`

Example:

```python
reviews = [
    [
        {
            "file": "pkg/webhook/handler.go",
            "line": 42,
            "severity": "high",
            "title": "Webhook URL not validated",
            "body": "No check for a well-formed HTTPS URL, which can enable SSRF."
        },
        {
            "severity": "low",
            "title": "Minor style inconsistency",
            "body": "Inconsistent with nearby code style."
        }
    ],
    []
]
```

If a step has no issues, use `[]`.

### Verify line numbers

Do not guess. Open the actual file and verify that any anchored `file`/`line` pair points to the intended code.

## Step 6: Choose the output location

Place the HTML file **outside the repo** to avoid polluting the checkout.

Default to something like:

```bash
../review-walkthrough-<branch-or-target>.html
```

If the user gave a preferred location, use it.

## Step 7: Generate the HTML

Use [template.html](template.html).

Each step object should look like:

```json
{
  "sha": "step-1",
  "message": "Step title shown in the header",
  "files": ["path/to/file.py", "path/to/other.py"],
  "diff": "the unified diff text for this step's files"
}
```

The `sha` field is just an identifier here. Use `step-1`, `step-2`, etc.

### Template placeholders

Replace these placeholders:

- `TITLE_PLACEHOLDER`
- `STEPS_PLACEHOLDER`
- `EXPLANATIONS_PLACEHOLDER`
- `REVIEWS_PLACEHOLDER`
- `PR_META_PLACEHOLDER`

`PR_META_PLACEHOLDER` should be a JSON object like:

```json
{"owner":"...","repo":"...","pr_number":123,"head_sha":"..."}
```

or `null`.

### Critical generation rule

**Do not try to inline the full generator with `python3 -c` or a heredoc.** The template contains `</script>`, `</div>`, and similar sequences that can break shell quoting or embedded script blocks.

Use the `write` tool to create a temporary Python file, then run it with `python3`.

Example shape:

```bash
python3 /tmp/gen_walkthrough.py
```

Inside the script, gather diff data with `subprocess` rather than stdin.

### Safe JSON embedding

**Escape `</` in serialized JSON** before embedding into the template, otherwise HTML in diffs can terminate the script tag in the browser.

```python
import json

with open('<skill-dir>/template.html') as f:
    html = f.read()

def safe_json(obj):
    return json.dumps(obj).replace('</', '<\\/')

html = html.replace('TITLE_PLACEHOLDER', title)
html = html.replace('STEPS_PLACEHOLDER', safe_json(steps))
html = html.replace('EXPLANATIONS_PLACEHOLDER', safe_json(explanations))
html = html.replace('REVIEWS_PLACEHOLDER', safe_json(reviews))
html = html.replace('PR_META_PLACEHOLDER', safe_json(pr_meta))

with open(output_path, 'w') as f:
    f.write(html)
```

## Step 8: Open it in the browser

On macOS:

```bash
open <output_path>
```

Tell the user where the file was written.

## Extracting per-step diffs from the full diff

Split the unified diff by file header, then recombine file chunks by step.

```python
import re

def split_diff_by_file(full_diff):
    chunks = re.split(r'(?=^diff --git )', full_diff, flags=re.MULTILINE)
    result = {}
    for chunk in chunks:
        if not chunk.strip():
            continue
        m = re.search(r'diff --git a/.+ b/(.+)', chunk)
        if m:
            result[m.group(1)] = chunk
    return result

file_diffs = split_diff_by_file(full_diff)

for step in steps:
    step['diff'] = '\n'.join(
        file_diffs[f] for f in step['files'] if f in file_diffs
    )
```

## Guidelines

- The reviewer should see the final state, not commit-by-commit history
- Order steps so prerequisites come first
- Keep explanations concise but substantive
- Be honest in the review; do not invent issues, but do flag real concerns
- Keep the HTML fully self-contained
- Do not modify repository files unless the user explicitly asks you to
