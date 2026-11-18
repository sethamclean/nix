{
  overlay,
  pkgs,
  userName,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ overlay ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Weekly GC of generations older than 14 days; recent ones stay for rollback.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  systemd.tmpfiles.rules = [
    "d /home/${userName}/ws 0755 ${userName} users -"
  ];
}
