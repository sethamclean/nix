{ pkgs }:
{
 Pkgs = [
    pkgs.nix
    pkgs.zsh
    pkgs.man
    pkgs.tealdeer
    pkgs.python311Packages.supervisor
    pkgs.git
    pkgs.gh
    pkgs.nodejs
    pkgs.yarn
    pkgs.neovim
  ];
}
