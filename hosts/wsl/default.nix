{
  hostName,
  lib,
  nixos-wsl,
  pkgsForPackages,
  stateVersion,
  userName,
  userExtraGroups,
  ...
}:
let
  dev = import ../../nix/packages.nix { pkgs = pkgsForPackages; };
in
{
  imports = [ nixos-wsl.nixosModules.default ];

  networking.hostName = hostName;

  system.stateVersion = stateVersion;

  users.mutableUsers = true;

  wsl.enable = true;
  wsl.defaultUser = userName;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = lib.mkForce (lib.unique ([ "wheel" ] ++ userExtraGroups));
    shell = pkgsForPackages.zsh;
  };

  systemd.tmpfiles.rules = [
    "d /home/${userName}/ws 0755 ${userName} users -"
  ];

  environment.systemPackages = dev.daemons ++ dev.cli;

  programs.zsh.enable = true;
}
