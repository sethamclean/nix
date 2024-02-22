{
  description = "My Layered Docker Image with Supervisor Example";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { config = { allowUnfree = true; }; inherit system; };
        dev = import ./packages.nix { pkgs=pkgs; };
        dockerImage = pkgs.dockerTools.buildImage {
          name = "seth-docker";
          tag = "latest";
          fromImage = "apline";
          copyToRoot = pkgs.buildEnv {
             name = "image-root";
             paths = dev.Pkgs;
             pathsToLink = [ "/bin" "/etc" "/var" ];
          };
          runAsRoot = ''
            #!${pkgs.runtimeShell}
            ${pkgs.dockerTools.shadowSetup}
            apk add --no-cache openssh
          '';
          config = {
            Cmd = [ "/bin/zsh" ];
          };
        };
      in {
        packages = { 
          dockerImage = dockerImage;
        };
        defaultPackage = dockerImage;
        devShell = pkgs.mkShell {
          buildInputs = dev.Pkgs;
        };
      }
    );
}
