{ pkgs }:
let
  g = import ./groups.nix { inherit pkgs; };
  userTools = g.core ++ g.ai ++ g.build ++ g.lang ++ g.cloud;

  codespace = g.daemons ++ userTools ++ g.gui;
in
{
  # Codespaces image: user toolchain plus the daemon tools (the daemons also get
  # their own root-run profile, see `daemons`).
  inherit codespace;
  daemons = g.daemons;

  # NixOS desktop. Services come from NixOS options, not packages.
  desktop = userTools ++ g.gui;

  # Ubuntu work laptop under the Nix package manager only. GUI apps and system
  # services stay with apt there.
  laptop = userTools;
}
