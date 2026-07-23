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
    packages.riscv-tests = pkgs.stdenv.mkDerivation {
      pname = "riscv-tests";
      version = "0.1.0";
      src = inputs.riscv-tests;

      nativeBuildInputs = with pkgs; [
        pkgsCross.riscv32-embedded.buildPackages.gcc
        autoconf
        automake
        which
      ];

      patches = [./env_p_link.patch];

      configureFlags = [
        "--with-xlen=32"
        "--prefix=${placeholder "out"}/"
      ];

      makeFlags = [
        "RISCV_PREFIX=riscv32-none-elf-"
      ];
    };
  };
}
