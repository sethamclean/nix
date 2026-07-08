{
  hostName,
  lib,
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
  networking.hostName = hostName;

  system.stateVersion = stateVersion;

  virtualisation.hypervGuest.enable = true;

  users.mutableUsers = true;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = true;
  security.rtkit.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.networkmanager.enable = true;

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgsForPackages.xdg-desktop-portal-gtk ];
  };

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = lib.mkForce (
      lib.unique (
        [
          "wheel"
          "networkmanager"
        ]
        ++ userExtraGroups
      )
    );
    shell = pkgsForPackages.zsh;
  };

  systemd.tmpfiles.rules = [
    "d /home/${userName}/ws 0755 ${userName} users -"
  ];

  environment.systemPackages = [
    pkgsForPackages.linuxPackages.hyperv-daemons
    pkgsForPackages.chromium
    pkgsForPackages.flatpak
  ]
  ++ dev.daemons
  ++ dev.cli;

  programs.zsh.enable = true;
}
