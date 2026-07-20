#!/usr/bin/env bash
set -euo pipefail

ISA_DIR="src/tests/isa"

for hex_file in "$ISA_DIR"/*.hex; do
    bak_file="${hex_file}.bak"
    mv "$hex_file" "$bak_file"
    
    awk '
    {
        bytes[NR] = $1
    }
    END {
        for (i = 1; i <= NR; i += 4) {
            b0 = bytes[i]
            b1 = (i+1 <= NR) ? bytes[i+1] : "00"
            b2 = (i+2 <= NR) ? bytes[i+2] : "00"
            b3 = (i+3 <= NR) ? bytes[i+3] : "00"
            print b3 b2 b1 b0
        }
    }
    ' "$bak_file" > "$hex_file"
    
    echo "Converted: $hex_file"
done

echo "All HEX files converted successfully."
