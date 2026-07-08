# Hosts

Host-specific machine configurations will live here.

- `wsl/` contains the NixOS-WSL machine configuration.
- `hyperv/` contains the NixOS machine configuration for a Hyper-V VM.

## Update paths

- WSL system packages come from `hosts/wsl/default.nix` and `nix/packages.nix`.
- Apply WSL changes with `sudo nixos-rebuild switch --flake .#wsl`.
- Hyper-V system packages come from `hosts/hyperv/default.nix` and `nix/packages.nix`.
- Apply Hyper-V changes with `sudo nixos-rebuild switch --flake .#hyperv --show-trace`.
- The Hyper-V target enables guest utilities, X11 + LightDM + i3, Chromium, PipeWire, and Flatpak.
- Zen browser is installed manually via Flatpak (`app.zen_browser.zen`).
- Codespaces root daemons come from `.#codespace-daemons` and are baked into the image's root profile during `docker build`.
- Codespaces user tools come from `.#default` and are baked into the `seth` profile during `docker build`.
- Image-level OS packages such as `sudo` still come from `apt` in `docker/Dockerfile`.
