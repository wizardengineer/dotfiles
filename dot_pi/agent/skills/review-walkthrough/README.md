# Review Walkthrough

Pi skill for generating an interactive HTML walkthrough of a branch, ref, or PR-oriented diff.

It produces a self-contained dark-themed HTML file that:

- splits a diff into logical review steps
- explains each step in reviewer-friendly order
- adds a critical review tab for each step
- optionally generates `gh api` commands for inline PR comments when PR metadata is available

## Usage

```text
/skill:review-walkthrough
/skill:review-walkthrough feat/my-branch
/skill:review-walkthrough HEAD~5..HEAD
```

You can also invoke it with natural language, for example:

- "make a review walkthrough for this branch"
- "walk me through these changes as an HTML review"

## Requirements

- `git`
- `gh`
- `python3`
- a local browser opener such as `open` on macOS

## Files

- `SKILL.md` — skill instructions
- `template.html` — self-contained walkthrough UI template

## Source

Adapted for Pi from the Trail of Bits internal `review-walkthrough` skill concept in `trailofbits/skills-internal` PR #335.
