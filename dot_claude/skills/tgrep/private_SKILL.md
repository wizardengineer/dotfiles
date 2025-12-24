---
name: tgrep
description: Semantic code search using tgrep MCP. Use this INSTEAD of Glob/Grep/Explore when searching for code, functions, classes, symbols, or understanding a codebase. ALWAYS call ensure_indexed first when opening a project. (user)
---

# tgrep - Semantic Code Search

Use tgrep for ALL code search tasks.

## When to Use tgrep (INSTEAD of Explore/Glob/Grep)

- "find code that..." / "where is..." / "show me..."
- Finding functions, classes, methods, symbols
- Understanding how code works
- Searching for implementation patterns
- Any codebase exploration or navigation

## Quick Start

```
mcp__tgrep__search(query="your search query")
```

The index is built automatically in the background. If you get no results, call:
```
mcp__tgrep__ensure_indexed(path=".")
```

## Query Types

**Structural** (exact symbol lookup):
- `func:get_response` - Find function by name
- `class:HttpRequest` - Find class by name
- `method:save*` - Wildcard matching
- `func:*lower*` - Contains matching

**Semantic** (natural language):
- `"error handling"` - Find error handling code
- `"ARM lowering"` - Find ARM lowering code
- `"memory allocation"` - Find memory allocation code

## Build Context

Before implementing a feature:
```
mcp__tgrep__build_context(task="implement retry logic")
```

## Examples

| User Query | tgrep Action |
|------------|--------------|
| "find ARM lowering code" | `search(query="ARM lowering")` |
| "where is the parse function" | `search(query="func:parse*")` |
| "how does error handling work" | `search(query="error handling")` |
| "show me HTTP routing" | `search(query="HTTP request routing")` |
