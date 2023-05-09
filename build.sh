#!/bin/sh
cd /tmp/starship/
cargo build \
    --target aarch64-linux-android \
    --no-default-features \
    --features notify,gix-features/zlib-stock,gix-features/rustsha1 \
    --release
