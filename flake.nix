{
  description = "My Layered Docker Image with Supervisor Example";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    workmux = {
      url = "github:raine/workmux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "github:sethamclean/dotfiles";
      flake = false;
    };
  };
  outputs =
    {
      dotfiles,
      self,
      home-manager,
      nixpkgs,
      flake-utils,
      nixos-wsl,
      workmux,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSystem = flake-utils.lib.eachSystem supportedSystems;
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ (import ./nix/overlays.nix { inherit workmux; }) ];
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

        packages = dev.standalone // {
          default = pkgs.buildEnv {
            name = "packages";
            paths = dev.all;
          };

          # Toolchain for the docker sbx image (docker/Dockerfile.sbx).
          sbx = pkgs.buildEnv {
            name = "sbx-packages";
            paths = dev.sbx;
          };

          codespace-daemons = pkgs.buildEnv {
            name = "codespace-daemons";
            paths = dev.codespaceDaemons;
          };
        };
      }
    )
    // {
      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit self nixos-wsl dotfiles;
          hostName = "wsl";
          stateVersion = "25.05";
          userName = "seth";
          userExtraGroups = [ ];
          pkgsForPackages = mkPkgs "x86_64-linux";
        };
        modules = [
          ./hosts/wsl/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit dotfiles;
              userName = "seth";
            };
            home-manager.users.seth = import ./home/seth;
          }
        ];
      };

      nixosConfigurations.hyperv = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit self dotfiles;
          hostName = "hyperv";
          stateVersion = "25.05";
          userName = "seth";
          userExtraGroups = [ ];
          pkgsForPackages = mkPkgs "x86_64-linux";
        };
        modules = [
          ./hosts/hyperv/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit dotfiles;
              userName = "seth";
            };
            home-manager.users.seth = import ./home/seth;
          }
        ];
      };
    };
}
