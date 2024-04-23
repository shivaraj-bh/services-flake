{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    # CI will override `services-flake` to run checks on the latest source
    services-flake.url = "github:juspay/services-flake";
    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.flake-root.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.pre-commit-hooks-nix.flakeModule
        inputs.hercules-ci-effects.flakeModule
        ./nix/pre-commit.nix
      ];

      hercules-ci.flake-update = {
        enable = true;
        autoMergeMethod = "merge";
        baseMerge.enable = true;
        createPullRequest = true;
        flakes = {
          "example/share-services/northwind".commitSummary = "chore(example/share-services/northwind): Update flake.lock";
          "example/simple".commitSummary = "chore(example/simple): Update flake.lock";
          "test".commitSummary = "chore(test): Update flake.lock";
        };
        when = {
          dayOfWeek = [ "Mon" ];
        };
      };
      herculesCI.ciSystems = [ "x86_64-linux" ];

      perSystem = { pkgs, lib, config, ... }: {
        treefmt = {
          projectRoot = inputs.services-flake;
          projectRootFile = "flake.nix";
          flakeCheck = false; # pre-commit-hooks.nix checks this
          programs = {
            nixpkgs-fmt.enable = true;
          };
        };
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.just
            config.pre-commit.settings.tools.commitizen
          ];
          inputsFrom = [
            config.treefmt.build.devShell
            config.pre-commit.devShell
          ];
          shellHook = ''
            echo
            echo "🍎🍎 Run 'just <recipe>' to get started"
            just
          '';
        };
      };
    };
}
