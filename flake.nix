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
          copyToRoot = pkgs.buildEnv {
             name = "image-root";
             paths = [
              pkgs.coreutils-full
              pkgs.findutils
              pkgs.gawk
              pkgs.gnused
              pkgs.gnugrep
              pkgs.ncurses
              pkgs.su
              pkgs.dockerTools.fakeNss
              pkgs.dockerTools.caCertificates
              pkgs.dockerTools.usrBinEnv
              pkgs.dockerTools.binSh
              ] ++ dev.Pkgs;
             pathsToLink = [ "/bin" "/etc" "/var" ];
          };
          runAsRoot = ''
            mkdir -p /root/ 
            usermod -d /root/ root
          '';
          config = {
            Cmd = [ "/bin/zsh" ];
          };
        };
      in {
        packages = { 
          docker = dockerImage;
        };
        defaultPackage = dockerImage;
        devShell = pkgs.mkShell {
          buildInputs = dev.Pkgs;
        };
      }
    );
}
