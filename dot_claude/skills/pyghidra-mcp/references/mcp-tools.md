# PyGhidra MCP Tool Reference

Complete parameter reference for all pyghidra-mcp MCP tools.

## Table of Contents

- [decompile_function](#decompile_function)
- [search_symbols_by_name](#search_symbols_by_name)
- [search_code](#search_code)
- [list_project_binaries](#list_project_binaries)
- [list_project_binary_metadata](#list_project_binary_metadata)
- [delete_project_binary](#delete_project_binary)
- [list_exports](#list_exports)
- [list_imports](#list_imports)
- [list_cross_references](#list_cross_references)
- [search_strings](#search_strings)
- [read_bytes](#read_bytes)
- [gen_callgraph](#gen_callgraph)
- [import_binary](#import_binary)

---

## decompile_function

Decompile a single function to pseudo-C code.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `binary_name` | string | yes | Name of the binary in the project |
| `name_or_address` | string | yes | Function name or hex address (e.g., `"0x08900100"`) |

Returns decompiled C code with function signature, local variables, and body.

## search_symbols_by_name

Search all symbols by case-insensitive substring match.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `binary_name` | string | yes | Binary name |
| `query` | string | yes | Substring to search for |
| `offset` | int | no | Pagination offset (default: 0) |
| `limit` | int | no | Max results (default: 50) |

Returns symbol names, addresses, and types.

## search_code

Search decompiled code using literal substring or semantic (ChromaDB) search.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `binary_name` | string | yes | Binary name |
| `query` | string | yes | Search query (substring or natural language) |
| `limit` | int | no | Max results (default: 10) |
| `search_mode` | string | no | `"semantic"`, `"literal"`, or `"both"` (default: `"both"`) |

Semantic search uses vector embeddings to find functionally similar code.

## list_project_binaries

List all binaries in the current Ghidra project.

No parameters. Returns JSON with program names, analysis status, and paths.

## list_project_binary_metadata

Get detailed metadata about a specific binary.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `binary_name` | string | yes | Binary name |

Returns: architecture, compiler, endianness, address size, MD5/SHA256 hashes,
creation date, executable format, function count, symbol count.

## delete_project_binary

Remove a binary from the Ghidra project.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `binary_name` | string | yes | Binary name to delete |

## list_exports

List exported symbols with optional regex filtering.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `binary_name` | string | yes | Binary name |
| `query` | string | no | Regex filter pattern |
| `offset` | int | no | Pagination offset |
| `limit` | int | no | Max results (default: 50) |

## list_imports

List imported symbols with optional regex filtering.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `binary_name` | string | yes | Binary name |
| `query` | string | no | Regex filter pattern |
| `offset` | int | no | Pagination offset |
| `limit` | int | no | Max results (default: 50) |

## list_cross_references

List all cross-references to/from a function or address.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `binary_name` | string | yes | Binary name |
| `name_or_address` | string | yes | Function name or hex address |

Returns list of xrefs with source/destination addresses and reference types.

## search_strings

Search for strings within the binary.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `binary_name` | string | yes | Binary name |
| `query` | string | yes | Search query |
| `limit` | int | no | Max results (default: 20) |

Uses both literal matching and semantic search over string contents.

## read_bytes

Read raw bytes from a memory address.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `binary_name` | string | yes | Binary name |
| `address` | string | yes | Hex address (e.g., `"0x08800000"`) |
| `size` | int | yes | Number of bytes to read |

Returns hex-encoded byte string.

## gen_callgraph

Generate a MermaidJS call graph diagram for a function.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `binary_name` | string | yes | Binary name |
| `function_name` | string | yes | Function name |
| `direction` | string | no | `"callers"`, `"callees"`, or `"both"` (default: `"both"`) |
| `depth` | int | no | Graph depth (default: 2) |

Returns MermaidJS graph definition that can be rendered as a diagram.

## import_binary

Import a new binary file into the Ghidra project.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `binary_path` | string | yes | Absolute path to the binary file |

Analysis runs in the background. Use `list_project_binaries()` to check progress.
