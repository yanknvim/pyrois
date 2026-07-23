#!/usr/bin/env bash
set -euo pipefail

ISA_DIR="${ISA_DIR:-src/tests/isa}"
mkdir -p "$ISA_DIR"

for elf in "$@"; do
    name=$(basename "$elf")
    tmp=$(mktemp)
    riscv32-none-elf-objcopy -O binary "$elf" "$tmp"
    xxd -p -c 4 "$tmp" | \
        awk '{print substr($0,7,2) substr($0,5,2) substr($0,3,2) substr($0,1,2)}' \
        > "$ISA_DIR/${name}.hex"
    rm -f "$tmp"
    echo "Generated $ISA_DIR/${name}.hex"
done
