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

