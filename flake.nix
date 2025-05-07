{
  description = "My Layered Docker Image with Supervisor Example";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          config = { allowUnfree = true; };
          inherit system;
        };
        # Create an empty customPkgs record if the directory doesn't exist
        customPkgs = if builtins.pathExists ./custom-packages then
          import ./custom-packages { inherit pkgs; }
        else
          { };
        dev = import ./packages.nix {
          inherit pkgs;
          inherit customPkgs;
        };
      in {
        # Use devShells instead of devShell (deprecated)
        devShells.default =
          pkgs.mkShell { buildInputs = [ dev.daemons dev.cli ]; };

        # Use packages instead of defaultPackage (deprecated)
        packages.default = pkgs.buildEnv {
          name = "packages";
          paths = dev.daemons ++ dev.cli;
        };
      });
}
