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
        dev = import ./packages.nix { pkgs = pkgs; };
      in {
        devShell = pkgs.mkShell { buildInputs = [ dev.daemons dev.cli ]; };
        defaultPackage = pkgs.buildEnv {
          name = "packages";
          paths = dev.daemons ++ dev.cli;
        };
      });
}
