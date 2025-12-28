# Optimization Patterns Reference

## Universal Principles

### 1. Algorithm First
Before micro-optimizing:
| Complexity | 1K items | 1M items | 1B items |
|------------|----------|----------|----------|
| O(n²) | 1ms | 16 min | 31 years |
| O(n log n) | 0.01ms | 20ms | 30s |
| O(n) | 0.001ms | 1ms | 1s |

**No amount of micro-optimization makes O(n²) competitive with O(n log n) at scale.**

### 2. Memory Access Patterns
Modern CPUs: ~1 cycle to compute, ~100+ cycles to fetch from RAM.

```
Sequential access:    [1][2][3][4][5] → Prefetcher happy, ~4 cycles/access
Random access:        [1][?][3][?][5] → Cache misses, ~100+ cycles/access
```

### 3. Cache Line Awareness
Cache line = 64 bytes on most systems.

```c
// Bad: False sharing (two threads on same cache line)
struct { int counter1; int counter2; } shared;

// Good: Padding to separate cache lines
struct { 
    int counter1; 
    char pad[60];  // Push counter2 to next cache line
    int counter2; 
} shared;
```

---

## Rust Optimization Patterns

### Memory & Allocation

**Pre-allocate collections:**
```rust
// Bad: Multiple reallocations
let mut v = Vec::new();
for i in 0..1000 { v.push(i); }

// Good: Single allocation
let mut v = Vec::with_capacity(1000);
for i in 0..1000 { v.push(i); }
```

**Avoid unnecessary clones:**
```rust
// Bad: Cloning in loop
for item in items.iter() {
    process(item.clone());
}

// Good: Borrow instead
for item in items.iter() {
    process(item);
}

// If you need owned, take ownership
for item in items.into_iter() {
    process(item);
}
```

**Use `Cow` for conditional ownership:**
```rust
use std::borrow::Cow;

fn process(input: &str) -> Cow<str> {
    if needs_modification(input) {
        Cow::Owned(modify(input))
    } else {
        Cow::Borrowed(input)  // Zero allocation
    }
}
```

### String Operations

**Avoid format! in hot paths:**
```rust
// Bad: Allocates every iteration
for i in 0..1000 {
    log(&format!("Processing {}", i));
}

// Good: Reuse buffer
use std::fmt::Write;
let mut buf = String::with_capacity(64);
for i in 0..1000 {
    buf.clear();
    write!(&mut buf, "Processing {}", i).unwrap();
    log(&buf);
}
```

**Use `push_str` over `+`:**
```rust
// Bad: Multiple allocations
let s = a + &b + &c;

// Good: Single allocation
let mut s = String::with_capacity(a.len() + b.len() + c.len());
s.push_str(&a);
s.push_str(&b);
s.push_str(&c);
```

### Iteration

**Prefer iterators (usually equivalent, sometimes better):**
```rust
// Both compile to same code
for i in 0..vec.len() { process(&vec[i]); }
for item in vec.iter() { process(item); }

// But iterators enable chaining optimizations
vec.iter().filter(|x| x > &5).map(|x| x * 2).sum()
```

**Avoid collect() when not needed:**
```rust
// Bad: Collects then iterates
let filtered: Vec<_> = items.iter().filter(|x| x > &5).collect();
for item in filtered { process(item); }

// Good: Lazy iteration
for item in items.iter().filter(|x| x > &5) {
    process(item);
}
```

### Data Structures

**Use appropriate hashers:**
```rust
// Default SipHash: Secure but slower
use std::collections::HashMap;

// FxHash: Much faster for non-adversarial input
use rustc_hash::FxHashMap;

// AHash: Fast + DoS resistant
use ahash::AHashMap;
```

**Consider SmallVec for small collections:**
```rust
use smallvec::SmallVec;

// Stack-allocated for <= 4 elements, heap for more
let mut v: SmallVec<[i32; 4]> = SmallVec::new();
```

### Compiler Hints

```rust
// Likely/unlikely branch hints (nightly)
#![feature(core_intrinsics)]
if std::intrinsics::likely(condition) { ... }

// Cold functions (rare paths)
#[cold]
fn handle_error() { ... }

// Inline always/never
#[inline(always)]
fn hot_function() { ... }

#[inline(never)]
fn cold_function() { ... }
```

---

## C/C++ Optimization Patterns

### Memory Layout

**Array of Structs vs Struct of Arrays:**
```cpp
// AoS: Bad cache utilization if only accessing one field
struct Particle { float x, y, z, vx, vy, vz; };
Particle particles[1000];

// SoA: Better if processing fields independently
struct Particles {
    float x[1000], y[1000], z[1000];
    float vx[1000], vy[1000], vz[1000];
};
```

**Alignment for SIMD:**
```cpp
// Ensure 32-byte alignment for AVX
alignas(32) float data[1024];

// Or use aligned_alloc
float* data = (float*)aligned_alloc(32, 1024 * sizeof(float));
```

### Loop Optimizations

**Loop unrolling (manual or hint):**
```cpp
// Let compiler unroll
#pragma GCC unroll 4
for (int i = 0; i < n; i++) { ... }

// Manual unrolling
for (int i = 0; i < n; i += 4) {
    process(data[i]);
    process(data[i+1]);
    process(data[i+2]);
    process(data[i+3]);
}
```

**Loop interchange for better cache access:**
```cpp
// Bad: Column-major access in row-major storage
for (int j = 0; j < cols; j++)
    for (int i = 0; i < rows; i++)
        matrix[i][j] = 0;

// Good: Row-major access
for (int i = 0; i < rows; i++)
    for (int j = 0; j < cols; j++)
        matrix[i][j] = 0;
```

### Move Semantics (C++)

**Enable move when possible:**
```cpp
class Buffer {
    std::vector<int> data;
public:
    // Move constructor
    Buffer(Buffer&& other) noexcept : data(std::move(other.data)) {}
    
    // Return by value (relies on NRVO/move)
    static Buffer create(size_t n) {
        Buffer b;
        b.data.resize(n);
        return b;  // Move or NRVO
    }
};
```

**Avoid copy in range-for:**
```cpp
// Bad: Copies each element
for (auto item : container) { ... }

// Good: Reference
for (const auto& item : container) { ... }

// If modifying:
for (auto& item : container) { ... }
```

### Branch Optimization

**Use branchless operations where possible:**
```cpp
// Branchy
int abs_val = (x < 0) ? -x : x;

// Branchless (compiler often does this)
int abs_val = (x ^ (x >> 31)) - (x >> 31);

// Or use intrinsics/stdlib
int abs_val = std::abs(x);
```

**Sort for predictable branches:**
```cpp
// If data has patterns, sorting can help branch prediction
std::sort(data.begin(), data.end());
for (auto x : data) {
    if (x > threshold) { ... }  // More predictable after sort
}
```

### Compiler-Specific

**GCC/Clang optimization attributes:**
```cpp
// Hot function (optimize aggressively)
__attribute__((hot))
void critical_path() { ... }

// Pure function (no side effects, same input = same output)
__attribute__((pure))
int compute(int x) { return x * x; }

// Const function (pure + doesn't read global memory)
__attribute__((const))
int square(int x) { return x * x; }
```

**Restrict pointers (no aliasing):**
```cpp
// Tell compiler these don't alias
void add(float* __restrict__ a, float* __restrict__ b, float* __restrict__ c, int n) {
    for (int i = 0; i < n; i++) {
        c[i] = a[i] + b[i];  // Compiler can vectorize safely
    }
}
```

---

## Python Optimization Patterns

### Leverage Built-ins

**Use built-in functions (C-implemented):**
```python
# Bad: Python loop
total = 0
for x in numbers:
    total += x

# Good: Built-in
total = sum(numbers)

# Also: min(), max(), any(), all(), sorted()
```

**List comprehensions over loops:**
```python
# Bad
result = []
for x in items:
    if x > 5:
        result.append(x * 2)

# Good (faster, more idiomatic)
result = [x * 2 for x in items if x > 5]
```

### Avoid Repeated Lookups

**Cache attribute lookups:**
```python
# Bad: Repeated attribute lookup
for i in range(len(data)):
    obj.method(data[i])

# Good: Cache method reference
method = obj.method
for i in range(len(data)):
    method(data[i])
```

**Cache global→local:**
```python
# Bad: Global lookup each iteration
def process():
    for item in items:
        result = GLOBAL_CONFIG['key']  # Dict lookup + global lookup

# Good: Local reference
def process():
    key_value = GLOBAL_CONFIG['key']
    for item in items:
        result = key_value
```

### String Operations

**Join over concatenation:**
```python
# Bad: O(n²) - creates new string each iteration
s = ""
for item in items:
    s += str(item)

# Good: O(n)
s = "".join(str(item) for item in items)
```

**f-strings are fastest for formatting:**
```python
# Slowest
s = "Hello " + name + "!"

# Medium
s = "Hello {}!".format(name)
s = "Hello %s!" % name

# Fastest
s = f"Hello {name}!"
```

### NumPy Vectorization

**Replace loops with vectorized operations:**
```python
# Bad: Python loop
result = []
for x in data:
    result.append(x ** 2 + 2 * x + 1)

# Good: NumPy vectorized
import numpy as np
data = np.array(data)
result = data ** 2 + 2 * data + 1  # 10-100x faster
```

**Use NumPy broadcasting:**
```python
# Bad: Nested loop
for i in range(len(a)):
    for j in range(len(b)):
        result[i, j] = a[i] * b[j]

# Good: Broadcasting
result = a[:, np.newaxis] * b[np.newaxis, :]
```

### Data Structures

**Use appropriate collections:**
```python
# Membership testing: set >> list
if item in my_list:     # O(n)
if item in my_set:      # O(1)

# Counting: Counter
from collections import Counter
counts = Counter(items)  # Faster than manual dict

# Default values: defaultdict
from collections import defaultdict
d = defaultdict(list)    # Faster than setdefault()

# Ordered iteration: Use list of tuples if order matters
# (dict maintains insertion order in Python 3.7+)
```

### Cython for Hot Paths

```python
# hot_function.pyx
cdef int inner_loop(int n):
    cdef int i, total = 0
    for i in range(n):
        total += i * i
    return total

# Compile: cythonize -i hot_function.pyx
# Use: from hot_function import inner_loop
```

### Avoiding Global Interpreter Lock (GIL)

```python
# CPU-bound: Use multiprocessing, not threading
from multiprocessing import Pool
with Pool(4) as p:
    results = p.map(cpu_intensive_func, data)

# I/O-bound: Threading is fine
from concurrent.futures import ThreadPoolExecutor
with ThreadPoolExecutor(max_workers=4) as e:
    results = list(e.map(io_func, urls))

# NumPy/Pandas operations release GIL automatically
```

---

## Cross-Language Anti-Patterns

### 1. Premature Optimization
```
# WRONG approach
1. Write code
2. Optimize everything
3. Profile to verify

# RIGHT approach
1. Write clear code
2. Profile to find bottlenecks
3. Optimize only the hot paths
```

### 2. Optimizing the Wrong Thing
```
# If profile shows:
# 80% time in function A
# 20% time in function B

# Optimizing B is mostly wasted effort
# Even 10x improvement in B → only 18% total speedup
# 2x improvement in A → 40% total speedup
```

### 3. Death by Abstraction
Each layer of abstraction can hide performance costs:
- Virtual function calls
- Dynamic dispatch
- Iterator overhead
- Exception handling
- Runtime type checks

Not saying avoid abstraction—just be aware of cost in hot paths.

### 4. Ignoring Memory
"If your program is slow and you're not I/O bound, you're probably memory bound."

Profile memory access patterns before optimizing CPU-intensive code.
