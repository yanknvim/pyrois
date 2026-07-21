{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    systems,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.git-hooks-nix.flakeModule
      ];
      systems = import systems;

      perSystem = {
        config,
        system,
        pkgs,
        ...
      }: {
        pre-commit = {
          check.enable = true;
          settings = {
            src = ./.;

            hooks = {
              alejandra.enable = true;

              veryl-fmt = {
                enable = true;
                name = "veryl-fmt";

                files = "\\.veryl$";
                entry = "${pkgs.veryl}/bin/veryl fmt --check";
              };
            };
          };
        };

        devShells.default = pkgs.mkShell {
          shellHook = ''
            ${config.pre-commit.shellHook}
          '';
          inputsFrom = [config.pre-commit.devShell];
          packages = with pkgs; [
            veryl

            gcc
            pkgsCross.riscv32-embedded.buildPackages.gcc
            pkgsCross.riscv32-embedded.buildPackages.binutils

            bash

            verilator
            gtkwave
          ];
        };
      };
    };
}
