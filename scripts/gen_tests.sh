#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

output="src/tests.veryl"
rm "$output"

shopt -s nullglob

{
  for f in src/tests/isa/*.hex; do
      base=$(basename "$f" .hex)
      name="test_${base//-/_}"
      cat << EOF
#[test($name)]
module $name {
    inst clk: \$tb::clock_gen;
    inst rst: \$tb::reset_gen(clk);

    var test_succeed: bit;
    inst top: Top #(HEX_FILE: "$f") (clk, rst, test_succeed);

    initial {
        rst.assert();
        clk.next(10000);
        \$assert(test_succeed == 1);
        \$finish();
    }
}

EOF
  done
} > "$output"

echo "Generated $output"
