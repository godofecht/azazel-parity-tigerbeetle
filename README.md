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

