# Hosts

Host-specific machine configurations will live here.

- `wsl/` contains the NixOS-WSL machine configuration.

## Update paths

- WSL system packages come from `hosts/wsl/default.nix` and `nix/packages.nix`.
- Apply WSL changes with `sudo nixos-rebuild switch --flake .#wsl`.
- Codespaces root daemons come from `.#codespace-daemons` and are baked into the image's root profile during `docker build`.
- Codespaces user tools come from `.#default` and are baked into the `seth` profile during `docker build`.
- Image-level OS packages such as `sudo` still come from `apt` in `docker/Dockerfile`.
