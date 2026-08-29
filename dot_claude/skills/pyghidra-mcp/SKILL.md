---
name: pyghidra-mcp
description: Ghidra reverse engineering via pyghidra-mcp MCP server. Use when analyzing binaries, decompiling functions, searching symbols/strings, viewing cross-references, generating call graphs, or importing binaries into Ghidra projects. Triggers on: binary analysis, reverse engineering, decompilation, disassembly, function analysis, symbol lookup, xref analysis, call graph generation, or any Ghidra-related task. Requires the pyghidra-mcp MCP server to be configured and running.
---

# PyGhidra MCP - Binary Analysis via Ghidra

Use the pyghidra-mcp MCP tools to perform reverse engineering and binary analysis through Ghidra's headless analysis engine.

## Available MCP Tools

### Binary Management

- **`list_project_binaries()`** - List all binaries in the Ghidra project with analysis status
- **`list_project_binary_metadata(binary_name)`** - Get architecture, compiler, endianness, hashes, function count
- **`import_binary(binary_path)`** - Import a new binary (analysis runs in background)
- **`delete_project_binary(binary_name)`** - Remove a binary from the project

### Decompilation & Code Analysis

- **`decompile_function(binary_name, name_or_address)`** - Decompile a function to pseudo-C. Accept function name or hex address (e.g., `"0x08900100"`)
- **`search_code(binary_name, query, limit, search_mode)`** - Semantic or literal search over decompiled code. `search_mode` can be `"semantic"` (ChromaDB vectors), `"literal"` (substring), or `"both"`
- **`read_bytes(binary_name, address, size)`** - Read raw hex bytes from a memory address

### Symbol & String Search

- **`search_symbols_by_name(binary_name, query, offset, limit)`** - Case-insensitive substring search across all symbols
- **`list_exports(binary_name, query, offset, limit)`** - List exported symbols with optional regex filter
- **`list_imports(binary_name, query, offset, limit)`** - List imported symbols with optional regex filter
- **`search_strings(binary_name, query, limit)`** - Search strings in the binary (literal + semantic)

### Cross-References & Call Graphs

- **`list_cross_references(binary_name, name_or_address)`** - List all xrefs to/from a function or address
- **`gen_callgraph(binary_name, function_name, direction, depth)`** - Generate MermaidJS call graph. `direction`: `"callers"`, `"callees"`, or `"both"`

## Common Workflows

### 1. Initial Binary Exploration

```
list_project_binaries()                          # See what's loaded
list_project_binary_metadata("BOOT.BIN")         # Architecture, function count
search_symbols_by_name("BOOT.BIN", "main")       # Find entry points
list_exports("BOOT.BIN", "", 0, 50)              # Browse exports
```

### 2. Function Deep-Dive

```
decompile_function("BOOT.BIN", "main")           # Get pseudo-C
list_cross_references("BOOT.BIN", "main")        # Who calls it / what it calls
gen_callgraph("BOOT.BIN", "main", "callees", 3)  # Visual call tree
```

### 3. String/Pattern Hunting

```
search_strings("BOOT.BIN", "error", 20)          # Find error strings
search_code("BOOT.BIN", "malloc", 10, "literal") # Find malloc usage
search_code("BOOT.BIN", "memory allocation and buffer handling", 10, "semantic")
```

### 4. Import and Analyze New Binary

```
import_binary("/path/to/binary.elf")             # Starts background analysis
list_project_binaries()                          # Check analysis progress
```

## MIPS/PSP-Specific Notes

When analyzing PSP (Allegrex/MIPS) binaries:
- Function addresses are typically in `0x08800000-0x09FFFFFF` range (user space)
- VFPU instructions may not fully decompile; check raw bytes with `read_bytes`
- Use `search_symbols_by_name` with `"sceKernel"`, `"sceGe"`, `"sceDisplay"` prefixes to find PSP SDK calls
- Cross-reference analysis is valuable for mapping the GE command dispatch

## MCP Server Configuration

For Claude Code, add to your MCP settings:

```json
{
  "mcpServers": {
    "pyghidra-mcp": {
      "command": "uvx",
      "args": ["pyghidra-mcp", "--wait-for-analysis", "/path/to/binary"],
      "env": {
        "GHIDRA_INSTALL_DIR": "/opt/homebrew/Cellar/ghidra/12.0.2/libexec"
      }
    }
  }
}
```

Key options: `--project-path <dir>`, `--threaded`, `--gdt <path>`, `--force-analysis`.

For full tool parameter details, see [references/mcp-tools.md](references/mcp-tools.md).
For setup and environment details, see [references/setup-guide.md](references/setup-guide.md).
