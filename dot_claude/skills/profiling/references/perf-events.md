# Hardware Performance Counters Reference

## Quick Reference: Most Useful Counters

```bash
# Essential performance overview
perf stat -e cycles,instructions,cache-references,cache-misses,branches,branch-misses ./program

# Memory-focused
perf stat -e L1-dcache-loads,L1-dcache-load-misses,LLC-loads,LLC-load-misses ./program

# Branch prediction
perf stat -e branches,branch-misses,branch-loads,branch-load-misses ./program
```

## Understanding Key Metrics

### Instructions Per Cycle (IPC)

```bash
perf stat -e cycles,instructions ./program
```

| IPC | Interpretation |
|-----|----------------|
| < 0.5 | Memory-bound, stalls waiting for data |
| 0.5-1.0 | Moderate efficiency, room for improvement |
| 1.0-2.0 | Good CPU utilization |
| > 2.0 | Excellent, likely vectorized or superscalar |

**Low IPC causes:**
- Cache misses (memory latency)
- Branch mispredictions (pipeline stalls)
- Data dependencies (instruction serialization)

### Cache Miss Rate

```bash
perf stat -e cache-references,cache-misses ./program
```

Calculate: `miss_rate = cache-misses / cache-references * 100`

| Miss Rate | Interpretation |
|-----------|----------------|
| < 1% | Excellent cache behavior |
| 1-5% | Good, typical for well-optimized code |
| 5-10% | Worth investigating |
| > 10% | Cache-unfriendly access patterns |

### Branch Misprediction Rate

```bash
perf stat -e branches,branch-misses ./program
```

Calculate: `miss_rate = branch-misses / branches * 100`

| Miss Rate | Interpretation |
|-----------|----------------|
| < 1% | Excellent, predictable branches |
| 1-5% | Normal for complex logic |
| 5-10% | Consider branch elimination |
| > 10% | Unpredictable patterns, major issue |

## Complete Event Categories

### CPU Cycles & Instructions

```bash
perf stat -e cycles,instructions,cpu-clock,task-clock ./program
```

| Event | Meaning |
|-------|---------|
| `cycles` | CPU clock cycles consumed |
| `instructions` | Instructions retired (completed) |
| `cpu-clock` | CPU time in milliseconds |
| `task-clock` | Time task was scheduled |

### Cache Events (L1 Data Cache)

```bash
perf stat -e L1-dcache-loads,L1-dcache-load-misses,L1-dcache-stores ./program
```

| Event | Meaning |
|-------|---------|
| `L1-dcache-loads` | L1 data cache read accesses |
| `L1-dcache-load-misses` | L1 data cache read misses |
| `L1-dcache-stores` | L1 data cache write accesses |

**L1 miss → L2 lookup (~10 cycles)**

### Cache Events (L1 Instruction Cache)

```bash
perf stat -e L1-icache-load-misses ./program
```

| Event | Meaning |
|-------|---------|
| `L1-icache-load-misses` | Instruction cache misses |

**High I-cache misses:** Code is too large/spread out, consider code locality.

### Last Level Cache (LLC/L3)

```bash
perf stat -e LLC-loads,LLC-load-misses,LLC-stores,LLC-store-misses ./program
```

| Event | Meaning |
|-------|---------|
| `LLC-loads` | Last level cache read requests |
| `LLC-load-misses` | LLC read misses (goes to RAM) |
| `LLC-stores` | LLC write requests |
| `LLC-store-misses` | LLC write misses |

**LLC miss → Main memory (~100-300 cycles)**

### Branch Events

```bash
perf stat -e branches,branch-misses,branch-loads,branch-load-misses ./program
```

| Event | Meaning |
|-------|---------|
| `branches` | All branch instructions |
| `branch-misses` | Mispredicted branches |
| `branch-loads` | Branch instruction fetches |
| `branch-load-misses` | Branch fetch misses |

**Misprediction cost:** ~15-20 cycles (pipeline flush)

### TLB Events

```bash
perf stat -e dTLB-loads,dTLB-load-misses,iTLB-load-misses ./program
```

| Event | Meaning |
|-------|---------|
| `dTLB-loads` | Data TLB accesses |
| `dTLB-load-misses` | Data TLB misses |
| `iTLB-load-misses` | Instruction TLB misses |

**High TLB misses:** Consider huge pages, improve memory locality.

```bash
# Enable transparent huge pages
echo madvise > /sys/kernel/mm/transparent_hugepage/enabled
```

### Context Switches & Migrations

```bash
perf stat -e context-switches,cpu-migrations,page-faults ./program
```

| Event | Meaning |
|-------|---------|
| `context-switches` | Kernel/user mode switches |
| `cpu-migrations` | Task moved to different CPU |
| `page-faults` | Memory page faults |
| `minor-faults` | Page in memory, just needs mapping |
| `major-faults` | Page had to be loaded from disk |

## Advanced Analysis

### Memory Bandwidth Estimation

```bash
perf stat -e LLC-loads,LLC-stores,LLC-load-misses,LLC-store-misses \
    -e cache-references,cache-misses ./program
```

Rough bandwidth = `(LLC-load-misses + LLC-store-misses) * 64 bytes / runtime`

### Stall Analysis

```bash
# Intel specific
perf stat -e cycles,cycle_activity.stalls_total,cycle_activity.stalls_mem_any ./program
```

### Memory Access Profiling

```bash
# Record memory accesses with addresses
perf mem record ./program
perf mem report

# Show which data addresses cause cache misses
perf c2c record ./program
perf c2c report
```

## Platform-Specific Events

### Intel Processors

```bash
# List available events
perf list

# Useful Intel-specific events
perf stat -e cpu/mem-loads/,cpu/mem-stores/ ./program

# Frontend/backend stalls
perf stat -e idq_uops_not_delivered.core,uops_retired.retire_slots ./program
```

### AMD Processors

```bash
# AMD-specific cache events
perf stat -e ls_dc_accesses,ls_dc_misses ./program
```

### ARM Processors

```bash
# ARM PMU events
perf stat -e armv8_pmuv3/inst_retired/,armv8_pmuv3/cpu_cycles/ ./program
```

## Recording vs Stat

**`perf stat`**: Aggregate counters, low overhead
```bash
perf stat -e <events> ./program
```

**`perf record`**: Sampled profiles, can annotate source
```bash
perf record -e <event> -c <sample_period> ./program
perf report
```

**`perf record` with multiple events:**
```bash
perf record -e cycles,cache-misses -c 10000 ./program
```

## Interpreting Results

### Example Output Analysis

```
Performance counter stats for './program':

     12,345,678,901      cycles                    
      8,765,432,109      instructions              #    0.71  insn per cycle
        234,567,890      cache-references          
         23,456,789      cache-misses              #   10.00 % of all cache refs
        456,789,012      branches                  
          4,567,890      branch-misses             #    1.00 % of all branches

       2.345678901 seconds time elapsed
```

**Analysis:**
- IPC = 0.71: Memory-bound (< 1.0)
- Cache miss = 10%: High, investigate access patterns
- Branch miss = 1%: Good, predictable code

**Optimization priority:**
1. Fix cache misses (10% is high)
2. Improve IPC through better cache utilization
3. Branch prediction is fine

## Gotchas

1. **Virtual machines**: Limited/emulated PMU, unreliable counts
2. **Containers**: May need `--privileged` or `CAP_PERFMON`
3. **Kernel versions**: Event names change between versions
4. **Multiplexing**: Too many events → estimates, not actual counts
5. **Root access**: Some events require `perf_event_paranoid` adjustment

```bash
# Check paranoid level
cat /proc/sys/kernel/perf_event_paranoid

# Allow user-space profiling (requires root)
echo 1 > /proc/sys/kernel/perf_event_paranoid
```
