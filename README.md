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

| Build | How `vsr_options` is supplied | Config size |
|-------|-------------------------------|-------------|
| azazel | `option_values`, declared as data | `project.cue`, 21 lines |
| zaza | `addOptions`, built imperatively | `build.zig`,       42 lines |
| upstream (native) | its own `build.zig` `addOptions` | `build.zig`,     2511 lines |

### Organizational structure

azazel states the four option values (including `git_commit: ?[40]u8`) as CUE
data; a module then imports `vsr_options` with no build code. zaza writes the
`b.addOptions()` calls directly. Both produce the same `libtb_vsr.a`. The trade
is data vs code for the same injected options module.
