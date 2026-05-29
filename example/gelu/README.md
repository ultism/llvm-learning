# GELU: scalar vs. AVX-512 (erf-based)

A small, self-contained study of the **exact, error-function form** of GELU,
implemented two ways and cross-checked against each other.

## What is GELU?

GELU (Gaussian Error Linear Unit) gates an input by the probability that a
standard normal variable is below it — `x * P(X <= x)`:

```
GELU(x) = x * Phi(x) = 0.5 * x * (1 + erf(x / sqrt(2)))
```

where `Phi` is the standard-normal CDF and `erf` is the Gauss error function.
This is the *exact* definition. (The popular `tanh` "approximate GELU" is a
cheaper stand-in for `erf` — not used here, since the goal is the erf path.)

## Files

| File             | Role                                                        |
|------------------|-------------------------------------------------------------|
| `gelu.h`         | Public API                                                  |
| `gelu_scalar.c`  | Scalar reference using libm `erff()` (the "ground truth")   |
| `gelu_avx512.c`  | AVX-512: GELU wrapper around SLEEF's vectorised `erf`, 16-wide |
| `main.c`         | Value table, accuracy sweep, throughput benchmark           |
| `Makefile`       | clang/LLVM build                                            |

## How the AVX-512 version works

There is no single x86 *machine instruction* for `erf`, but a **vectorised
`erf` is readily available on any AVX-512 CPU — Intel and AMD (Zen 4/5) alike**.
You can hand-roll a polynomial, link Intel SVML, use glibc `libmvec`, or — as
here — use **[SLEEF](https://sleef.org)**, an open, portable vector-math library.

So `gelu_avx512.c` is tiny:

1. **`Sleef_erff16_u10`** — SLEEF's 16-wide (`__m512`) single-precision `erf`,
   accurate to **≤ 1.0 ULP**. (`16` = 512 bits / 32-bit float ⇒ AVX-512F.)

2. **`gelu512_ps`** — assembles `0.5 * x * (1 + erf(x/sqrt2))` around it with a
   couple of `_mm512_mul_ps` / `_mm512_add_ps`.

3. **`gelu_avx512_array`** — processes 16 floats per iteration; the trailing
   `< 16` elements use a **write mask** (`_mm512_maskz_loadu_ps` /
   `_mm512_mask_storeu_ps`) so any array length is safe — no scalar tail loop.

## Install SLEEF

```sh
sudo apt-get install -y libsleef-dev          # Ubuntu/Debian (universe)
# header: /usr/include/<triple>/sleef.h, link with -lsleef
```

## Build & run

```sh
make        # clang -O3 -march=native ... -lsleef  (AVX-512 on Zen 4/5)
make run    # build + ./gelu_demo.out
```

Requires a CPU with **AVX-512F** (AMD Zen 4/5, Intel Skylake-X and later).

## Sample results (Ryzen 7 9800X3D, clang 15, SLEEF 3.5.1)

```
  Accuracy over [-8, 8], 1048576 points:
    max |scalar - avx512|             = 2.384e-07     # SLEEF erf is <= 1 ULP
    max relative error (|GELU| > 0.1) = 4.470e-07

  Throughput (200 reps x 1048576 elems):
    scalar : ~1647 ms    ~127 Melem/s
    avx512 :  ~271 ms    ~774 Melem/s   (~6x)
```

Note the trade-off vs. a hand-rolled polynomial: SLEEF's `erf` is more accurate
(1 ULP) and battle-tested, but each call is a **shared-library call** through the
PLT (not inlined) and does more work for that accuracy — so it lands around ~6x
here rather than the ~35x a crude inlined polynomial reaches. For maximum speed
SLEEF also ships header-only *inline* variants (`sleefinline_avx512f.h`); the
Debian package used here provides only the shared library.
(Relative error is reported only where `|GELU| > 0.1` — near the origin GELU is
tiny, so absolute error is the meaningful metric.)
