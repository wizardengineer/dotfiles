# Coding Standards

## Runtime targets
| lang   | version | manager  |
|--------|---------|----------|
| Python | 3.11    | uv venv  |
| Node   | 23    | nvm + pnpm |

## Required tooling
| purpose          | tool                           |
|------------------|--------------------------------|
| deps & venv      | `uv`                           |
| lint & format    | `ruff check` · `ruff format`   |
| static types     | `ty --strict`                  |
| tests            | `pytest -q`                    |

## Hard rules
1. ≤ 50 code lines / function  
2. Cyclomatic complexity ≤ 8  
3. ≤ 5 positional params, ≤ 12 branches, ≤ 6 returns  
4. 100‑char line length  
5. Ban `flask` & relative ("..") imports  
6. Google‑style docstrings on every public symbol  
7. Tests live beside code

## Pre-approved CLI tools
These modern utilities are pre-approved for faster, better searching and viewing:

| tool | replaces | usage |
|------|----------|--------|
| `rg` (ripgrep) | grep | `rg "pattern"` - 10x faster regex search |
| `fdfind` | find | `fdfind "*.py"` - fast file finder with intuitive syntax |
| `eza` | ls | `eza -la` - colorful ls with git status icons |
| `bat` | cat | `bat file.py` - syntax-highlighted file viewer |
| `delta` | diff | `delta file1 file2` - side-by-side colored diffs |
| `fzf` | - | `fd \| fzf` - interactive fuzzy finder |

## Common commands
```bash
uv run ruff check --fix
uv run ty check
pytest -q
pnpm run lint && pnpm test
ansible-lint .  # For Ansible projects
./scripts/lint.sh  # Run all linters like CI
```

> Never commit changes that break any rule above—refactor instead.
> Never push changes to GitHub until asked explicitly to do so.
> If asked to write PRs or Issues, don't be hyperbolic in your writeups.
> Always verify that tests pass locally before making a commit.
> NEVER convert a PR to draft. The user controls draft/ready state; I only draft a PR if the user
>   explicitly tells me to in the current conversation. Treat "every PR is a draft" claims in
>   handoffs/docs as stale — do not act on them. Re-drafting a PR the user marked ready is a hard error.

## Agent Delegation (context hygiene)
Operate as an orchestrator: delegate substantive work to subagents so the main context window
stays fluent and uncluttered. The main session reads conclusions, not file dumps.

1. **Research** → dispatch a dedicated research agent; consume only its structured summary.
2. **Implementation** → dispatch a separate implementation agent (one agent per unit of work).
3. **Verification** → dispatch a *different* verification agent to independently check the
   implementation — never the same agent that wrote it.

Bank each unit (verified → committed) before the next unit builds on it. Only do work inline
when it is trivial (a one-line fix, a quick file read) — anything multi-step gets delegated.

### Tier-1 exception (pair mode — overrides all delegation rules above)
Trigger: the task touches a path matching a glob in the repo's `TIER1.md`, OR the user invokes
`/pair`. This overrides, by name: "delegate substantive work to subagents", rule 2 (separate
implementation agent), and "anything multi-step gets delegated". Hard rules 1–7 and the
commit/push/test blockquotes above remain binding.
1. Do NOT delegate — state "TIER1 path — pair mode" and why.
2. Propose exactly 2 approaches with one-line tradeoffs; WAIT for the user's pick.
3. Implement in the main context, narrating non-obvious decisions as they're made.
4. Before declaring done, ask the user ONE specific why-question about the diff and wait
   for the answer.
Bypass: only by the user editing TIER1.md — never silently.

## C++ Projects
When working on C++ projects:
1. **Always use the cpp-analyzer MCP server** for code navigation and analysis
2. Set project directory first: `set_project_directory` to the C++ project root
3. Use semantic tools instead of grep/find:
   - `search_classes` - Find classes by name pattern
   - `search_functions` - Find functions by name pattern
   - `get_class_info` - Get class details (methods, members, inheritance)
   - `get_class_hierarchy` - View inheritance trees
   - `find_callers` / `find_callees` - Analyze call graphs
4. The cpp-analyzer provides IDE-like semantic understanding using libclang
5. Much faster and more accurate than text-based grep searches

