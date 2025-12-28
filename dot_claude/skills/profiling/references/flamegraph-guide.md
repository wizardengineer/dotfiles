# Flamegraph Interpretation Guide

## Reading Flamegraphs

Flamegraphs visualize stack traces where:
- **X-axis**: Proportion of time (not chronological order)
- **Y-axis**: Stack depth (callers below, callees above)
- **Width**: Time spent in that function AND its children
- **Color**: Usually random or indicates category (no performance meaning)

## Key Patterns to Recognize

### 1. Flat Top ("Plateau")
```
┌──────────────────────────────────────┐
│           hot_function()             │
├──────────────────────────────────────┤
│              caller()                │
└──────────────────────────────────────┘
```
**Meaning**: `hot_function` is where CPU time is actually spent.
**Action**: Optimize this function directly.

### 2. Wide Base, Narrow Top ("Tower")
```
        ┌──┐
        │  │ many_small_calls()
    ┌───┴──┴───┐
    │          │ dispatcher()
┌───┴──────────┴───┐
│                  │ main_loop()
└──────────────────┘
```
**Meaning**: Loop overhead, many small function calls.
**Action**: Consider inlining, batching, or reducing call frequency.

### 3. Multiple Peaks ("Mountain Range")
```
┌────┐        ┌────┐       ┌──────┐
│    │        │    │       │      │
├────┴────────┴────┴───────┴──────┤
│           process()              │
└──────────────────────────────────┘
```
**Meaning**: Multiple distinct operations consuming similar time.
**Action**: Optimize each peak independently, prioritize by width.

### 4. Deep Narrow Stack ("Spike")
```
┌┐
││ leaf()
├┤
││ mid3()
├┤
││ mid2()
├┤
││ mid1()
├┴───────────────┐
│   caller()     │
└────────────────┘
```
**Meaning**: Deep call stack but not much time spent.
**Action**: Usually not a problem unless the depth causes stack overflow.

### 5. Recursive Pattern ("Stairs")
```
┌─┐
│ │ recursive(n)
├─┴─┐
│   │ recursive(n-1)
├───┴─┐
│     │ recursive(n-2)
├─────┴─┐
│       │ recursive(n-3)
└───────┘
```
**Meaning**: Recursive algorithm with visible depth.
**Action**: Consider iteration, memoization, or tail-call optimization.

## Common Performance Culprits in Flamegraphs

### Memory Allocation
Look for: `malloc`, `free`, `operator new`, `__rust_alloc`, `PyObject_Malloc`
```
┌─────────────────────┐
│    malloc/free      │   <- If wide, excessive allocation
├─────────────────────┤
│   your_function()   │
```
**Fix**: Pre-allocate, use object pools, arena allocators, or `with_capacity()`.

### String Operations
Look for: `memcpy`, `strlen`, `str::to_string`, `format!`, `PyUnicode`
```
┌─────────────────────┐
│      memcpy         │
├─────────────────────┤
│  string_concat()    │
```
**Fix**: Use string builders, avoid repeated concatenation, pre-allocate buffers.

### Lock Contention
Look for: `pthread_mutex_lock`, `__lll_lock_wait`, `parking_lot::*`
```
┌─────────────────────┐
│   __lll_lock_wait   │   <- Thread blocking
├─────────────────────┤
│   pthread_mutex     │
├─────────────────────┤
│   your_sync_fn()    │
```
**Fix**: Reduce critical section size, use lock-free structures, partition data.

### Hash Operations
Look for: `hashbrown::*`, `std::hash`, `siphash`, `_PyHash`
```
┌─────────────────────┐
│     hash_one()      │
├─────────────────────┤
│   HashMap::get()    │
```
**Fix**: Use faster hashers (FxHash, AHash), pre-size hash maps, consider alternatives.

### Serialization
Look for: `serde::*`, `json::*`, `protobuf::*`, `pickle`
```
┌─────────────────────┐
│   serde_json::*     │
├─────────────────────┤
│    serialize()      │
```
**Fix**: Use binary formats, zero-copy deserialization, or avoid serialization in hot paths.

## Language-Specific Symbols

### Rust
- `core::ptr::drop_in_place` - Destructor overhead
- `alloc::alloc::*` - Heap allocation
- `<T as core::clone::Clone>::clone` - Clone operations
- `core::fmt::*` - String formatting
- `hashbrown::raw::*` - HashMap internals

### C++
- `std::vector::*` - Vector operations
- `std::__cxx11::basic_string` - String operations
- `__dynamic_cast` - RTTI/dynamic dispatch
- `operator new/delete` - Allocation
- `std::shared_ptr::*` - Reference counting

### Python
- `_PyEval_EvalFrameDefault` - Bytecode interpretation
- `PyObject_Call` - Function calls
- `PyDict_GetItem` - Dictionary lookup
- `list_*`, `dict_*` - Built-in operations
- `gc_collect` - Garbage collection

## Differential Flamegraphs

Compare two profiles to see what changed:

```bash
# Generate differential flamegraph
difffolded.pl baseline.folded current.folded | flamegraph.pl > diff.svg
```

**Red** = More time in new version (regression)
**Blue** = Less time in new version (improvement)

## Tools for Flamegraph Generation

### Linux
```bash
# perf + FlameGraph scripts
perf record -g ./program
perf script | stackcollapse-perf.pl | flamegraph.pl > flame.svg

# Brendan Gregg's FlameGraph repo
git clone https://github.com/brendangregg/FlameGraph
```

### Rust
```bash
# cargo-flamegraph (easiest)
cargo install flamegraph
cargo flamegraph

# With specific binary
cargo flamegraph --bin mybin -- arg1 arg2
```

### Python
```bash
# py-spy
pip install py-spy
py-spy record -o flame.svg -- python script.py
```

### macOS
```bash
# samply (opens Firefox Profiler)
cargo install samply
samply record ./program
```

## Interactive Viewers

For better exploration than SVG:
- **Firefox Profiler** (https://profiler.firefox.com) - Upload perf.script output
- **Speedscope** (https://speedscope.app) - Upload various formats
- **Perfetto** (https://ui.perfetto.dev) - Chrome traces and perf data
