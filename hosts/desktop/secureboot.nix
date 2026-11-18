{
  lanzaboote,
  lib,
  pkgs,
  ...
}:
# Secure Boot with lanzaboote, which replaces systemd-boot with signed boot
# images. Signing keys live in /var/lib/sbctl and must exist before a rebuild:
# `sudo sbctl create-keys`. The firmware key enrollment steps are in README.md.
{
  imports = [ lanzaboote.nixosModules.lanzaboote ];

  environment.systemPackages = [ pkgs.sbctl ];

  # lanzaboote replaces systemd-boot.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    # Keep /boot from filling with signed images; older generations stay in the store.
    configurationLimit = 10;
  };
}
