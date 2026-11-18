{
  catppuccin,
  lib,
  pkgs,
  userName,
  ...
}:
let
  profiles = import ../../nix/profiles.nix { inherit pkgs; };

  # Ultrawide split: 25% | 50% | 25%. Tile coordinates are fractions of the monitor.
  ultrawideLayout = {
    id = "ultrawide-25-50-25";
    tiles = [
      { x = 0;    y = 0; width = 0.25; height = 1; groups = [ 1 ]; }
      { x = 0.25; y = 0; width = 0.5;  height = 1; groups = [ 1 2 ]; }
      { x = 0.75; y = 0; width = 0.25; height = 1; groups = [ 2 ]; }
    ];
  };
in
{
  imports = [
    catppuccin.nixosModules.catppuccin
    ./hardware-configuration.nix
    ./openshell.nix
    ./secureboot.nix
  ];

  # Catppuccin Mocha. Without home-manager the NixOS module covers only the
  # cursors and the console; icons, dark mode and borders are set below.
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
    cursors.enable = true;
  };

  system.stateVersion = "26.05";

  # Boot
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Network
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # GPU: NVIDIA (PCI 10de:2c02). nouveau caps the Neo G9 at 3840x1080.
  # Open kernel modules are required on Blackwell.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };

  # Desktop
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.printing.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User
  users.users.${userName} = {
    description = "Seth";
    extraGroups = [ "networkmanager" ];
    # Tools come from the shared `desktop` profile (nix/profiles.nix).
    packages = profiles.desktop;
  };

  # Services
  # Rootless: the daemon runs as `seth` (user service), so no docker group.
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  services.tailscale.enable = true;

  # Run generic-Linux glibc binaries (stub-ld otherwise refuses them). The OpenShell
  # VM driver extracts and runs an upstream `openshell-supervisor` on the host.
  programs.nix-ld.enable = true;

  # Browsers
  programs.firefox.enable = true;
  environment.systemPackages = [
    pkgs.google-chrome
    pkgs.gnomeExtensions.tiling-shell
    pkgs.xdg-terminal-exec
    (pkgs.catppuccin-papirus-folders.override {
      flavor = "mocha";
      accent = "mauve";
    })
  ];

  # Nerd Font: icons for terminals and Neovim (Source Code Pro, patched).
  fonts.packages = [ pkgs.nerd-fonts.sauce-code-pro ];

  # Default browser. ~/.config/mimeapps.list overrides this when it names a handler.
  xdg.mime.defaultApplications = lib.genAttrs [
    "text/html"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
  ] (_: "google-chrome.desktop");

  # Default terminal: GNOME already calls xdg-terminal-exec; this names Ghostty.
  environment.etc."xdg/xdg-terminals.list".text = ''
    com.mitchellh.ghostty.desktop
  '';

  # Ghostty is D-Bus activated, and GNOME's launcher needs the session bus to find
  # its service file. Per-user packages are not on that search path.
  services.dbus.packages = [ pkgs.ghostty ];

  # Enable GNOME extensions system-wide (no home-manager in this repo).
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/shell".enabled-extensions = [
        "tilingshell@ferrarodomenico.com"
      ];
      settings."org/gnome/shell".always-show-log-out = true;

      # Super+Return opens the default terminal (see xdg-terminals.list).
      settings."org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
      ];
      settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal" = {
        name = "Terminal";
        command = "${pkgs.xdg-terminal-exec}/bin/xdg-terminal-exec";
        binding = "<Super>Return";
      };

      # Super+hjkl focuses windows (Tiling Shell). Move the two GNOME defaults on h and l.
      settings."org/gnome/desktop/wm/keybindings".minimize = [ "<Super><Shift>h" ];

      settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        accent-color = "purple";
        icon-theme = "Papirus-Dark";
        cursor-theme = "catppuccin-mocha-mauve-cursors";
      };

      # Smaller server-side titlebars (default is Adwaita Sans Bold 11).
      settings."org/gnome/desktop/wm/preferences".titlebar-font = "Adwaita Sans Bold 9";
      settings."org/gnome/settings-daemon/plugins/media-keys".screensaver = [ "<Super><Shift>l" ];

      settings."org/gnome/shell/extensions/tilingshell" = {
        focus-window-left = [ "<Super>h" ];
        focus-window-down = [ "<Super>j" ];
        focus-window-up = [ "<Super>k" ];
        focus-window-right = [ "<Super>l" ];
        inner-gaps = lib.gvariant.mkUint32 4;
        outer-gaps = lib.gvariant.mkUint32 4;
        layouts-json = builtins.toJSON [ ultrawideLayout ];
        selected-layouts = [ [ ultrawideLayout.id ] ];
        enable-tiling-system-windows-suggestions = true;
        enable-autotiling = true;
        enable-window-border = true;
        window-use-custom-border-color = true;
        window-border-color = "#cba6f7";
        window-border-width = lib.gvariant.mkUint32 2;
      };
    }
  ];
}
