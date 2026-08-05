#!/bin/sh
# Stage tigerbeetle source at a pinned commit into vendor/tigerbeetle
# (git-ignored). tigerbeetle is zero-dependency std-only. Requires git.
set -eu
TB_COMMIT=97c7a8ef385270ebe0e1b75959d3d21d134629df
DIR=$(cd "$(dirname "$0")" && pwd)
VENDOR="$DIR/vendor/tigerbeetle"
if [ -f "$VENDOR/src/vsr.zig" ]; then echo "already staged"; exit 0; fi
rm -rf "$VENDOR"; mkdir -p "$DIR/vendor"
git clone --filter=blob:none https://github.com/tigerbeetle/tigerbeetle "$VENDOR"
git -C "$VENDOR" checkout -q "$TB_COMMIT"
echo "tigerbeetle staged"
