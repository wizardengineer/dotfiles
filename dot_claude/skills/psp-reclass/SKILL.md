---
name: psp-reclass
description: Inspect PSP game memory via PPSSPP debugger API or psprecomp-rs runtime debug socket. Use when investigating memory structures, vtables, pointer chains, or diffing PPSSPP vs runtime memory.
---

# PSP ReClass Skill

## Auto-Detect PPSSPP Port

Before any command, detect the PPSSPP debugger port automatically:

```bash
PPSSPP_PORT=$(lsof -i -P | grep -i PPSSPP | grep LISTEN | awk '{print $9}' | sed 's/.*://')
```

If empty, PPSSPP isn't running or debugger isn't enabled. Tell the user:
"PPSSPP debugger not detected. Launch PPSSPP, enable remote debugger in Settings > Tools > Developer Tools."

## Auto-Detect Runtime Debug Socket

Check if the psprecomp-rs runtime debug socket is active:

```bash
RUNTIME_PORT=$(lsof -i :9999 -sTCP:LISTEN 2>/dev/null | grep -v COMMAND | awk '{print 9999}')
```

## tmux Session

All psp-reclass commands run in a dedicated tmux session so the user can watch:

```bash
tmux has-session -t psp-reclass 2>/dev/null || tmux new-session -d -s psp-reclass -c ~/Projects/PersonalWork/psp-reclass
```

User attaches with: `tmux attach -t psp-reclass`

For visible commands: `tmux send-keys -t psp-reclass 'COMMAND' Enter`
For agent-only data: run directly via Bash with `--json`

## Commands

All run from `~/Projects/PersonalWork/psp-reclass`.

### One-shot CLI (connects, runs, exits — no crash on exit)
```bash
cd ~/Projects/PersonalWork/psp-reclass && npx tsx src/cli/index.ts <command> --port=$PPSSPP_PORT
```

### REPL (persistent connection — for multi-command sessions)
```bash
cd ~/Projects/PersonalWork/psp-reclass && npx tsx src/cli/repl.ts --port=$PPSSPP_PORT
```

Pipe commands to REPL for scripted sessions:
```bash
echo -e "rm 0x08800000 64\nrs 0x08000100 NativeModule" | npx tsx src/cli/repl.ts --port=$PPSSPP_PORT
```

### Available Commands

| Command | One-shot | REPL shortcut |
|---------|----------|---------------|
| Read memory | `read-memory <addr> [size]` | `rm` |
| Read struct | `read-struct <addr> <name>` | `rs` |
| Follow pointer | `follow-pointer <addr> [depth]` | `fp` |
| Detect vtable | `vtable <addr> [max]` | `vt` |
| Read uint32 | (use read-memory) | `u32` |
| Diff memory | `diff <addr> [size] --ppsspp-port=P --runtime-port=R` | — |
| List structs | `list-structs` | `ls` |
| Export headers | `export-headers [file]` | `eh` |

### Flags
- `--port=PORT` — target port (auto-detected above)
- `--target=ppsspp|runtime` — select backend (default: ppsspp)
- `--json` — structured JSON output
- `--structs=DIR` — struct definitions dir (default: structs/)

## Key Workflows

### Inspect a struct at a known address
```bash
PPSSPP_PORT=$(lsof -i -P | grep -i PPSSPP | grep LISTEN | awk '{print $9}' | sed 's/.*://')
cd ~/Projects/PersonalWork/psp-reclass && npx tsx src/cli/index.ts read-struct 0x08A49308 SgxState --port=$PPSSPP_PORT
```

### Diff PPSSPP vs runtime memory
```bash
PPSSPP_PORT=$(lsof -i -P | grep -i PPSSPP | grep LISTEN | awk '{print $9}' | sed 's/.*://')
cd ~/Projects/PersonalWork/psp-reclass && npx tsx src/cli/index.ts diff 0x08A49308 64 --ppsspp-port=$PPSSPP_PORT --runtime-port=9999
```

### Export C++ headers (offline — no PPSSPP needed)
```bash
cd ~/Projects/PersonalWork/psp-reclass && npx tsx src/cli/index.ts export-headers psp_structs.h
```
