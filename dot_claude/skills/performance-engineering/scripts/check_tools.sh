#!/usr/bin/env bash
# Check availability of performance profiling tools
# Usage: ./check_tools.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ok() { echo -e "${GREEN}✓${NC} $*"; }
missing() { echo -e "${RED}✗${NC} $*"; }
optional() { echo -e "${YELLOW}○${NC} $*"; }
section() { echo -e "\n${BLUE}=== $* ===${NC}"; }

check() {
    local name="$1"
    local install_hint="${2:-}"
    if command -v "$name" &>/dev/null; then
        ok "$name ($(command -v "$name"))"
        return 0
    else
        if [[ -n "$install_hint" ]]; then
            missing "$name - $install_hint"
        else
            missing "$name"
        fi
        return 1
    fi
}

check_optional() {
    local name="$1"
    local install_hint="${2:-}"
    if command -v "$name" &>/dev/null; then
        ok "$name"
        return 0
    else
        optional "$name (optional) - $install_hint"
        return 1
    fi
}

OS=$(uname -s)
echo "Detected OS: $OS"

section "Essential Tools"
check hyperfine "cargo install hyperfine OR brew install hyperfine"

section "CPU Profiling"
if [[ "$OS" == "Linux" ]]; then
    check perf "apt install linux-tools-generic OR dnf install perf"
    check_optional flamegraph.pl "git clone https://github.com/brendangregg/FlameGraph"
    check_optional stackcollapse-perf.pl "included with FlameGraph"
elif [[ "$OS" == "Darwin" ]]; then
    check_optional samply "cargo install samply"
    check_optional instruments "Xcode Command Line Tools"
fi

check_optional cargo-flamegraph "cargo install flamegraph"

section "Memory Profiling"
if [[ "$OS" == "Linux" ]]; then
    check_optional heaptrack "apt install heaptrack heaptrack-gui"
    check valgrind "apt install valgrind"
    check_optional massif-visualizer "apt install massif-visualizer"
elif [[ "$OS" == "Darwin" ]]; then
    ok "leaks (built-in)"
fi

section "Cache & Hardware Counters"
if [[ "$OS" == "Linux" ]]; then
    check perf "(see above)"
    
    echo -n "perf_event_paranoid: "
    if [[ -f /proc/sys/kernel/perf_event_paranoid ]]; then
        level=$(cat /proc/sys/kernel/perf_event_paranoid)
        case $level in
            -1) ok "$level (full access)" ;;
            0|1) ok "$level (user-space profiling enabled)" ;;
            2) optional "$level (limited - run: sudo sysctl -w kernel.perf_event_paranoid=1)" ;;
            *) missing "$level (restricted)" ;;
        esac
    else
        missing "not available"
    fi
fi

section "System Call Tracing"
if [[ "$OS" == "Linux" ]]; then
    check strace "apt install strace"
    check_optional ltrace "apt install ltrace"
elif [[ "$OS" == "Darwin" ]]; then
    ok "dtruss (built-in, requires sudo)"
    ok "fs_usage (built-in, requires sudo)"
fi

section "Rust-Specific"
check cargo "https://rustup.rs"
check_optional cargo-flamegraph "cargo install flamegraph"
check_optional cargo-asm "cargo install cargo-asm"
check_optional cargo-llvm-lines "cargo install cargo-llvm-lines"
check_optional samply "cargo install samply"

section "C/C++-Specific"
check_optional gprof "included with GCC"
check_optional objdump "apt install binutils"
check_optional addr2line "apt install binutils"
check_optional c++filt "apt install binutils"
check_optional clang "apt install clang OR brew install llvm"

# Check for ClangBuildAnalyzer
check_optional ClangBuildAnalyzer "https://github.com/aras-p/ClangBuildAnalyzer"

section "Python-Specific"
check python3 "apt install python3"
check_optional py-spy "pip install py-spy"
check_optional scalene "pip install scalene"

# Check Python modules
if command -v python3 &>/dev/null; then
    for mod in cProfile memory_profiler line_profiler; do
        if python3 -c "import $mod" 2>/dev/null; then
            ok "python3 -m $mod"
        else
            optional "python3 -m $mod - pip install ${mod//_/-}"
        fi
    done
fi

section "Visualization"
check_optional speedscope "npm install -g speedscope OR https://speedscope.app"
check_optional hotspot "apt install hotspot (Linux GUI for perf)"

section "Summary"
echo ""
echo "Essential tools for this skill:"
echo "  Linux: perf, valgrind, hyperfine, FlameGraph scripts"
echo "  macOS: samply, Instruments, hyperfine"
echo "  Rust:  cargo-flamegraph"
echo "  Python: py-spy"
echo ""
echo "Run profiling with: ./scripts/profile.sh <mode> <command>"
