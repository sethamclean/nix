{ pkgs }:
{
  browser-testing = import ./browser-testing.nix { inherit pkgs; };
}
