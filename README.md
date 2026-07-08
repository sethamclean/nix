# Nix Workspace

This repo drives two different targets:

- `nixosConfigurations.wsl` for the WSL host.
- `nixosConfigurations.hyperv` for the Hyper-V VM host.
- Flake packages for the Codespaces image and user toolchain.

## Update Matrix

| Target | Source of truth | How to apply |
| --- | --- | --- |
| WSL system packages | `hosts/wsl/default.nix`, `nix/packages.nix` | `sudo nixos-rebuild switch --flake .#wsl` |
| Hyper-V VM system packages | `hosts/hyperv/default.nix`, `nix/packages.nix` | `sudo nixos-rebuild switch --flake .#hyperv --show-trace` |
| Codespaces root daemons | `.#codespace-daemons` | Rebuild the Docker image |
| Codespaces user tools | `.#default` | Rebuild the Docker image, or run `nix profile upgrade nix` from `~/ws/nix` |
| Image OS packages | `docker/Dockerfile` apt steps | Rebuild the Docker image |

## Hyper-V Notes

- The `hyperv` target enables Hyper-V guest integration, X11 with LightDM + i3, Chromium, PipeWire, and Flatpak support.
- Use Chromium for Teams and install web apps as Chromium app shortcuts (PWA-style) as needed.
- Install Zen manually via Flatpak on the VM:

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub app.zen_browser.zen
```

- Launch Zen with `flatpak run app.zen_browser.zen`.

## Codespaces Notes

- `seth` is the interactive user and gets the `.#default` Nix profile.
- Root-run services use the root Nix profile populated from `.#codespace-daemons`.
- `sudo` is installed in the image and `seth` has passwordless sudo for container admin tasks.
- `~/ws` is the canonical workspace path. In Codespaces it points at `/workspaces`.

## Cache Strategy

- Docker builds cache through both GitHub Actions cache storage and a registry-backed `buildcache` tag in GHCR.
- The expensive Nix profile layers only depend on `flake.nix`, `flake.lock`, and `nix/`, so docs and workflow edits do not invalidate them.
- Nix still pulls prebuilt store paths from upstream binary caches when a Docker layer cache miss happens.
- The image build runs daily to keep the Docker cache warm and refresh the base image.
- `flake_update.yml` runs weekly to refresh pinned Nix inputs.
- `cleanup.yaml` runs weekly and keeps the latest 10 container versions so cache continuity is less likely to be pruned away.

## Typical Commands

```bash
# Verify flake outputs
nix flake show .

# Rebuild the Codespaces image locally
docker build -f docker/Dockerfile .

# Upgrade the user profile in an existing Codespace after changing nix/packages.nix
cd ~/ws/nix
nix profile upgrade nix
```
