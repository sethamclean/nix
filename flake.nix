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
              pkgs.shadow
              pkgs.sudo
              pkgs.dockerTools.fakeNss
              pkgs.dockerTools.caCertificates
              pkgs.dockerTools.usrBinEnv
              pkgs.dockerTools.binSh
              ] ++ dev.Pkgs;
             pathsToLink = [ "/bin" "/etc" "/var" ];
          };
          runAsRoot = ''
            #!${pkgs.runtimeShell}
            ${pkgs.dockerTools.shadowSetup}
            sudo groupadd -g 22 sshd
            sudo groupadd -g 1000 seth
            sudo groupadd -g 10 wheel
            sudo useradd -r -g sshd sshd
            sudo useradd -u 1000 -g seth seth
            sudo usermmod -aG wheel seth
            sudo echo "wheel ALL=(ALL) NOPASSWD: ALL\n" >> /etc/sudoers 
            sudo mkdir -p  /home/seth && chown seth:seth /home/seth
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
