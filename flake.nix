{
  description = "Seth's package profiles (Codespaces, Ubuntu laptop) and NixOS desktop";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    workmux = {
      url = "github:raine/workmux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      lanzaboote,
      workmux,
      catppuccin,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSystem = flake-utils.lib.eachSystem supportedSystems;
      overlay = import ./nix/overlays.nix { inherit workmux; };
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ overlay ];
        };
      mkNixos =
        host:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit lanzaboote catppuccin overlay;
            userName = "seth";
          };
          modules = [
            ./hosts/common.nix
            host
          ];
        };
    in
    forEachSystem (
      system:
      let
        pkgs = mkPkgs system;
        profiles = import ./nix/profiles.nix { inherit pkgs; };
        mkEnv = name: paths: pkgs.buildEnv { inherit name paths; };
      in
      {
        devShells.default = pkgs.mkShell { buildInputs = profiles.codespace; };

        packages = (import ./nix/pkgs { inherit pkgs; }) // {
          default = mkEnv "packages" profiles.codespace;
          codespace = mkEnv "codespace-packages" profiles.codespace;
          desktop = mkEnv "desktop-packages" profiles.desktop;
          laptop = mkEnv "laptop-packages" profiles.laptop;
          codespace-daemons = mkEnv "codespace-daemons" profiles.daemons;
        };
      }
    )
    // {
      nixosConfigurations.desktop = mkNixos ./hosts/desktop;
    };
}
