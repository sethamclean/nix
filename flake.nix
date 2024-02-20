{
  description = "My Layered Docker Image with Supervisor Example";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        dev = import ./packages.nix { pkgs=pkgs; };
        dockerImage = pkgs.dockerTools.buildImage {
          name = "my-layered-image";
           copyToRoot = pkgs.buildEnv {
              name = "image-root";
              paths = dev.Pkgs;
           };
           config = {
             Entrypoint = [ "/usr/bin/supervisord" ];  # Set Supervisor as the entry point
             Cmd = [ "-c" "/etc/supervisord.conf" ];   # Specify Supervisor config file
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
