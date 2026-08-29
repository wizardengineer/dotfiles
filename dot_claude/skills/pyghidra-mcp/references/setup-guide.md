# PyGhidra MCP Setup Guide

## Prerequisites

- **Ghidra** installed locally (11.3.2+ recommended, 12.0+ ideal)
- **Python 3.10+**
- **Java 21** (OpenJDK recommended, required by Ghidra 12.x)
- **GHIDRA_INSTALL_DIR** environment variable set to Ghidra's install root

## Installation Methods

### Method 1: uvx (no install needed)

```bash
export GHIDRA_INSTALL_DIR="/opt/homebrew/Cellar/ghidra/12.0.2/libexec"
uvx pyghidra-mcp /path/to/binary
```

### Method 2: pip install

```bash
pip install pyghidra-mcp
```

### Method 3: From source

```bash
git clone https://github.com/clearbluejar/pyghidra-mcp
cd pyghidra-mcp
pip install -e ".[dev]"
```

### Method 4: Docker

```bash
docker run -i --rm \
  -v /path/to/binaries:/binaries \
  ghcr.io/clearbluejar/pyghidra-mcp \
  -t stdio /binaries/target
```

## Claude Code MCP Configuration

Add to project-level `.mcp.json` or global MCP settings:

```json
{
  "mcpServers": {
    "pyghidra-mcp": {
      "command": "uvx",
      "args": [
        "pyghidra-mcp",
        "--wait-for-analysis",
        "--project-path", "/tmp/pyghidra-projects",
        "/path/to/binary"
      ],
      "env": {
        "GHIDRA_INSTALL_DIR": "/opt/homebrew/Cellar/ghidra/12.0.2/libexec"
      }
    }
  }
}
```

### Analyzing multiple binaries

Pass multiple paths as args:

```json
{
  "args": [
    "pyghidra-mcp",
    "--wait-for-analysis",
    "--threaded",
    "/path/to/binary1",
    "/path/to/binary2"
  ]
}
```

### Opening existing Ghidra project

Point `--project-path` to an existing `.gpr` file:

```json
{
  "args": [
    "pyghidra-mcp",
    "--project-path", "/path/to/existing/project.gpr",
    "--wait-for-analysis"
  ]
}
```

## CLI Options Reference

| Option | Default | Description |
|--------|---------|-------------|
| `-t, --transport` | `stdio` | Transport: `stdio`, `streamable-http`, `sse` |
| `--project-path` | `pyghidra_mcp_projects` | Ghidra project dir or `.gpr` file |
| `--project-name` | `my_project` | Project name (ignored if opening `.gpr`) |
| `-p, --port` | `8000` | HTTP port (for http/sse transport) |
| `--threaded` | off | Enable multithreaded analysis |
| `--force-analysis` | off | Force re-analysis of already-analyzed binaries |
| `--wait-for-analysis` | off | Block startup until analysis completes |
| `--gdt` | none | Path to GDT (Ghidra Data Type) files |
| `--gzfs-path` | auto | Where to store GZF exports |
| `--no-symbols` | off | Skip symbol loading |
| `--max-workers` | CPU count | Thread pool size |

## macOS/Homebrew Ghidra Paths

For Homebrew-installed Ghidra 12.0.2:

```
GHIDRA_INSTALL_DIR=/opt/homebrew/Cellar/ghidra/12.0.2/libexec
analyzeHeadless: /opt/homebrew/Cellar/ghidra/12.0.2/libexec/support/analyzeHeadless
pyghidraRun:     /opt/homebrew/Cellar/ghidra/12.0.2/libexec/support/pyghidraRun
Java:            /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
```

## Ghidra Feature Compatibility

Your Ghidra 12.0.2 installation includes all features pyghidra-mcp depends on:

- **PyGhidra** - Bundled in Ghidra 12.x as `Ghidra/Features/PyGhidra/`
- **Decompiler** - Core feature, always present
- **MIPS Processor** - Available at `Ghidra/Processors/MIPS/`
- **FileFormats** - ELF, PE, Mach-O, and more

## Project Directory Structure

When pyghidra-mcp runs, it creates:

```
project-path/
  project-name.gpr           # Ghidra project file
  project-name.rep/          # Ghidra repository data
  project-name-pyghidra-mcp/ # pyghidra-mcp artifacts
    chromadb/                 # Vector embeddings for semantic search
    gzfs/                     # GZF exports of analyzed binaries
```

## Troubleshooting

**"Python 3 is not installed"**: Ensure `python3` is on PATH.

**JVM errors**: Verify `JAVA_HOME` or let Ghidra's bundled scripts handle it.
Ghidra 12.x requires Java 21.

**Analysis hangs**: Use `--wait-for-analysis` to block until analysis completes.
Without it, the server starts accepting requests while analysis runs in background.

**ARM64 macOS**: Ghidra native binaries may need rebuilding. Check if
`$GHIDRA_INSTALL_DIR/support/buildNatives` exists and run it.
