#!/usr/bin/env bash

# Install rust-analyzer LSP for Rust
#
# 1 - tool absolute path destination

set -euxo pipefail

bin_dest=$1
curl -L \
     https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz \
    | gunzip -c - > $bin_dest
chmod +x $bin_dest
