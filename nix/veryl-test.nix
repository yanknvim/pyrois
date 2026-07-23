{
  lib,
  inputs,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    checks.veryl-rv32ui-p = pkgs.stdenv.mkDerivation {
      pname = "veryl-rv32ui-p";
      version = "0.1.0";
      src = inputs.self;

      nativeBuildInputs = with pkgs; [
        veryl
        gcc
        pkgsCross.riscv32-embedded.buildPackages.binutils
        xxd
      ];

      buildInputs = [config.packages.riscv-tests];

      buildPhase = ''
        export HOME=$TMPDIR

        # Convert ELF binaries from riscv-tests to word-oriented hex files
        mkdir -p src/tests/isa
        for elf in ${config.packages.riscv-tests}/share/riscv-tests/isa/rv32ui-p-*; do
          if [[ -f "$elf" && ! "$elf" =~ \.dump$ ]]; then
            name=$(basename "$elf")
            tmp=$(mktemp)
            riscv32-none-elf-objcopy -O binary "$elf" "$tmp"
            xxd -p -c 4 "$tmp" | \
              awk '{print substr($0,7,2) substr($0,5,2) substr($0,3,2) substr($0,1,2)}' \
              > "src/tests/isa/''${name}.hex"
            rm -f "$tmp"
          fi
        done

        # Generate test bench from hex files
        HEX_DIR=src/tests/isa bash scripts/gen_tests.sh

        veryl test -t rv32ui_p
      '';

      installPhase = ''
        touch $out
      '';
    };
  };
}
