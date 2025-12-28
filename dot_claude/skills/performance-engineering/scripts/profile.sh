#!/usr/bin/env bash
# Quick profiling helper for Rust, C/C++, and Python projects
# Usage: ./profile.sh <command> [args...]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${PROFILE_OUTPUT_DIR:-/tmp/profile-output}"
mkdir -p "$OUTPUT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        *)       echo "unknown" ;;
    esac
}

OS=$(detect_os)

# Check tool availability
check_tool() {
    if command -v "$1" &>/dev/null; then
        return 0
    fi
    return 1
}

# Quick CPU profile
cpu_profile() {
    local cmd=("$@")
    info "CPU profiling: ${cmd[*]}"
    
    if [[ "$OS" == "linux" ]] && check_tool perf; then
        local perf_data="$OUTPUT_DIR/perf.data"
        info "Using perf (Linux)"
        perf record -g --call-graph dwarf -o "$perf_data" -- "${cmd[@]}"
        
        if check_tool flamegraph.pl; then
            info "Generating flamegraph..."
            perf script -i "$perf_data" | stackcollapse-perf.pl | flamegraph.pl > "$OUTPUT_DIR/flamegraph.svg"
            success "Flamegraph: $OUTPUT_DIR/flamegraph.svg"
        fi
        
        info "Top functions:"
        perf report -i "$perf_data" --stdio --sort=comm,dso,symbol 2>/dev/null | head -30
        
    elif [[ "$OS" == "macos" ]] && check_tool samply; then
        info "Using samply (macOS)"
        samply record -o "$OUTPUT_DIR/profile.json" -- "${cmd[@]}"
        success "Profile saved, opening Firefox Profiler..."
        
    elif check_tool py-spy && [[ "${cmd[0]}" == "python"* ]]; then
        info "Using py-spy (Python)"
        py-spy record -o "$OUTPUT_DIR/flamegraph.svg" -- "${cmd[@]}"
        success "Flamegraph: $OUTPUT_DIR/flamegraph.svg"
        
    else
        error "No suitable profiler found"
        echo "Linux: Install 'perf' (linux-tools-generic) and FlameGraph scripts"
        echo "macOS: Install 'samply' (cargo install samply)"
        echo "Python: Install 'py-spy' (pip install py-spy)"
        return 1
    fi
}

# Memory profiling
memory_profile() {
    local cmd=("$@")
    info "Memory profiling: ${cmd[*]}"
    
    if [[ "$OS" == "linux" ]] && check_tool heaptrack; then
        info "Using heaptrack"
        heaptrack -o "$OUTPUT_DIR/heaptrack" -- "${cmd[@]}"
        success "Run 'heaptrack_gui $OUTPUT_DIR/heaptrack.*.gz' to analyze"
        
    elif [[ "$OS" == "linux" ]] && check_tool valgrind; then
        info "Using valgrind massif"
        valgrind --tool=massif --massif-out-file="$OUTPUT_DIR/massif.out" -- "${cmd[@]}"
        ms_print "$OUTPUT_DIR/massif.out" > "$OUTPUT_DIR/massif_report.txt"
        success "Report: $OUTPUT_DIR/massif_report.txt"
        
    elif [[ "$OS" == "macos" ]] && check_tool leaks; then
        info "Using leaks (macOS)"
        leaks --atExit -- "${cmd[@]}" 2>&1 | tee "$OUTPUT_DIR/leaks.txt"
        success "Report: $OUTPUT_DIR/leaks.txt"
        
    else
        error "No memory profiler found"
        echo "Linux: Install 'heaptrack' or 'valgrind'"
        echo "macOS: 'leaks' is built-in"
        return 1
    fi
}

# Cache analysis
cache_analysis() {
    local cmd=("$@")
    info "Cache analysis: ${cmd[*]}"
    
    if [[ "$OS" == "linux" ]] && check_tool perf; then
        info "Cache statistics:"
        perf stat -e cache-references,cache-misses,L1-dcache-loads,L1-dcache-load-misses,LLC-loads,LLC-load-misses -- "${cmd[@]}" 2>&1 | tee "$OUTPUT_DIR/cache_stats.txt"
        success "Report: $OUTPUT_DIR/cache_stats.txt"
        
    elif [[ "$OS" == "linux" ]] && check_tool valgrind; then
        info "Using cachegrind"
        valgrind --tool=cachegrind --cachegrind-out-file="$OUTPUT_DIR/cachegrind.out" -- "${cmd[@]}"
        cg_annotate "$OUTPUT_DIR/cachegrind.out" > "$OUTPUT_DIR/cachegrind_report.txt"
        success "Report: $OUTPUT_DIR/cachegrind_report.txt"
        
    else
        error "Cache analysis requires 'perf' or 'valgrind' (Linux only)"
        return 1
    fi
}

# Quick stats (minimal overhead)
quick_stats() {
    local cmd=("$@")
    info "Quick stats: ${cmd[*]}"
    
    if [[ "$OS" == "linux" ]] && check_tool perf; then
        perf stat -e cycles,instructions,cache-references,cache-misses,branches,branch-misses -- "${cmd[@]}"
        
    else
        # Fallback to time
        /usr/bin/time -v "${cmd[@]}" 2>&1 | grep -E "(Elapsed|Maximum resident|Minor|Major|Voluntary)"
    fi
}

# Syscall analysis
syscall_analysis() {
    local cmd=("$@")
    info "Syscall analysis: ${cmd[*]}"
    
    if [[ "$OS" == "linux" ]] && check_tool strace; then
        strace -c -o "$OUTPUT_DIR/strace_summary.txt" -- "${cmd[@]}"
        success "Summary: $OUTPUT_DIR/strace_summary.txt"
        cat "$OUTPUT_DIR/strace_summary.txt"
        
    elif [[ "$OS" == "macos" ]] && check_tool dtruss; then
        warn "dtruss requires sudo"
        sudo dtruss -c "${cmd[@]}" 2>&1 | tee "$OUTPUT_DIR/dtruss.txt"
        success "Report: $OUTPUT_DIR/dtruss.txt"
        
    else
        error "No syscall tracer found (strace/dtruss)"
        return 1
    fi
}

# Benchmark with hyperfine
benchmark() {
    local cmd=("$@")
    info "Benchmarking: ${cmd[*]}"
    
    if check_tool hyperfine; then
        hyperfine --warmup 3 --runs 10 --export-json "$OUTPUT_DIR/benchmark.json" -- "${cmd[*]}"
        success "Results: $OUTPUT_DIR/benchmark.json"
    else
        warn "hyperfine not found, using basic timing"
        for i in {1..5}; do
            /usr/bin/time -f "Run $i: %e seconds" "${cmd[@]}" 2>&1 >/dev/null
        done
    fi
}

# Usage
usage() {
    cat << EOF
Performance Profiling Helper

Usage: $0 <mode> <command> [args...]

Modes:
  cpu       CPU/sampling profile with flamegraph
  memory    Heap allocation analysis
  cache     Cache miss analysis
  syscall   System call tracing
  stats     Quick performance counters
  bench     Benchmark with multiple runs

Examples:
  $0 cpu ./target/release/myprogram arg1 arg2
  $0 memory python script.py
  $0 cache ./a.out
  $0 bench cargo run --release

Environment:
  PROFILE_OUTPUT_DIR  Output directory (default: /tmp/profile-output)

Current OS: $OS
Output: $OUTPUT_DIR
EOF
}

# Main
main() {
    if [[ $# -lt 2 ]]; then
        usage
        exit 1
    fi
    
    local mode="$1"
    shift
    
    case "$mode" in
        cpu)      cpu_profile "$@" ;;
        memory)   memory_profile "$@" ;;
        cache)    cache_analysis "$@" ;;
        syscall)  syscall_analysis "$@" ;;
        stats)    quick_stats "$@" ;;
        bench)    benchmark "$@" ;;
        *)
            error "Unknown mode: $mode"
            usage
            exit 1
            ;;
    esac
}

main "$@"
