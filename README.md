# azazel-parity-tigerbeetle

[tigerbeetle](https://github.com/tigerbeetle/tigerbeetle)'s VSR library built two
ways, to prove and compare [azazel](https://github.com/godofecht/azazel) and
[zaza](https://github.com/godofecht/zaza).

tigerbeetle is zero-dependency pure Zig. Its `src/vsr.zig` reads a
`vsr_options` module that tigerbeetle's own `build.zig` synthesizes from
generated values (a git commit, release versions, an assertion flag). Both
builds here supply that module and compile the whole VSR library from source.

The interesting difference is how each supplies `vsr_options`:

- **azazel** declares the option values as **data** in the CUE model
  (`option_values`), including the `?[40]u8` git-commit field.
- **zaza** builds the same module **imperatively** with `addOptions` in a
  `build.zig`, the way tigerbeetle's own build does.

Neither vendors tigerbeetle's source.

## Pinned upstream

| | |
|---|---|
| Repository | https://github.com/tigerbeetle/tigerbeetle |
| Commit | `97c7a8ef385270ebe0e1b75959d3d21d134629df` |
| Zig | 0.14.1 (tigerbeetle's pinned toolchain) |

## Build it

```sh
cd azazel && ./fetch.sh && sh gen_build_spec.sh && zig build   # -> zig-out/lib/libtb_vsr.a
cd zaza  && ./fetch.sh && zig build                            # -> zig-out/lib/libtb_vsr.a
```

## Comparison

Clean-cache builds with dependencies pre-fetched, Apple Silicon, fastest of two runs.
`native` is tigerbeetle's own full `zig build`.

| Build | Clean build | Config |
|-------|-------------|--------|
| azazel | 3.2 s | `project.cue` — 21 lines · 848 B |
| zaza | 3.0 s | `build.zig` — 42 lines · 1591 B |
| native (tigerbeetle's own full `zig build`) | 12.0 s | — |

**The scoped VSR slice compiles in ~3 s against tigerbeetle's ~12 s full build — azazel and zaza are ~3.7x faster because they build only what the slice needs.**


## Build process & what can be optimized

Both build roots stage the pinned upstream with `fetch.sh` into a git-ignored
`vendor/` (a `curl` for single-file slices, a shallow clone for source trees) —
no upstream sources are committed. Then:

- **azazel**: `sh gen_build_spec.sh` runs CUE and emits `build_spec.zig` (the
  build declared as data), then `zig build` compiles it. The CUE step is
  memoized — it re-runs only when the model changes (~0.20s → ~0.01s otherwise).
- **zaza**: `zig build` drives the standard Zig build graph directly.

### What actually makes it faster

Measured across the corpus (clean vs warm builds):

| Lever | Speedup | Note |
|-------|---------|------|
| Content-addressed cache (rebuild) | **89×** | 14.2s → 0.16s; Zig has it, both inherit it |
| Incremental (edit one file) | **10.8×** | 14.2s → 1.32s; deps stay cached |
| CI dependency cache | **2×** | cold 13.3s → warm 6.6s; this repo's CI caches `~/.cache/zig` |
| Memoized CUE codegen | **20×** | azazel's only overhead, gone |
| Parallelism (many cores) | **1.1×** | marginal — shared `std` + startup dominate |
| GPU | none | compilation is branchy, sequential, dependency-ordered |

The instinct to parallelize like a C++ build doesn't transfer: Zig is one
mostly-single-threaded compile per artifact with a fast self-hosted backend and a
shared `std` that caches. **For Zig, caching is the lever, not parallelism.**

The real frontier is *residency*: a resident compile server that keeps the
InternPool hot and recompiles only changed declarations, plus in-place binary
patching (Zig's roadmap) and a shared content-addressed cache. azazel's
build-as-data is positioned for it — the build is a query, and the cache key is
computable from the pinned model without running the compiler. Full write-up and
the cross-repo comparison: the [corpus dashboard](https://claude.ai/code/artifact/8c37ee83-b358-4351-a1e0-eb02ec0aedd4).
