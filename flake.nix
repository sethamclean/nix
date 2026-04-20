{
  description = "My Layered Docker Image with Supervisor Example";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nixos-wsl,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = flake-utils.lib.eachSystem supportedSystems;
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      mkDev = pkgs: import ./nix/packages.nix { inherit pkgs; };
    in
    forEachSystem (
      system:
      let
        pkgs = mkPkgs system;
        dev = mkDev pkgs;
      in
      {
        devShells.default = pkgs.mkShell { buildInputs = dev.all; };

        packages.default = pkgs.buildEnv {
          name = "packages";
          paths = dev.all;
        };

        packages.codespace-daemons = pkgs.buildEnv {
          name = "codespace-daemons";
          paths = dev.codespaceDaemons;
        };
      }
    )
    // {
      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit self nixos-wsl;
          hostName = "wsl";
          stateVersion = "25.05";
          userName = "seth";
          userExtraGroups = [ ];
          pkgsForPackages = mkPkgs "x86_64-linux";
        };
        modules = [
          ./hosts/wsl/default.nix
        ];
      };
    };
}
