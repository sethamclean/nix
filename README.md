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
| Codespaces daemon profile (`seth`) | `.#codespace-daemons` | Rebuild the Docker image |
| Codespaces user tools | `.#default` | Rebuild the Docker image, or run `nix profile upgrade nix` from `~/ws/nix` |
| Image OS packages | `docker/Dockerfile` apt steps | Rebuild the Docker image |
| docker sbx user tools | `.#sbx` (`sbx` list in `nix/packages.nix`) | Rebuild the sbx image (`docker/Dockerfile.sbx`) |

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
- Root-run services use a dedicated daemon profile at `/nix/var/nix/profiles/per-user/seth/daemons` populated from `.#codespace-daemons`.
- `codebase-memory-mcp` runs under supervisord as `seth` with its UI on port `9749`, and a companion indexer re-indexes every git repo under `/workspaces` every 10 minutes (`CBM_ALLOWED_ROOT=/workspaces`).
- `ws-doc-server` runs under supervisord as `seth` on `127.0.0.1:8765` from `/home/seth/.local/bin/ws-doc-server` (installed by `make install` in `/workspaces/mcp-servers/ws-doc-server`). It fails with a clear log message if the binary is missing.
- `tmux-mcp` runs under supervisord as `seth` on `127.0.0.1:8766` (MCP over HTTP at `/mcp`, read-only) from `/home/seth/.local/bin/tmux-mcp`, installed by `make install` in `/workspaces/mcp-servers`. It fails with a clear log message if the binary is missing.
- `sudo` is installed in the image and `seth` has passwordless sudo for container admin tasks.
- `~/ws` is the canonical workspace path. In Codespaces it points at `/workspaces`.

## docker sbx Image

`docker/Dockerfile.sbx` builds a flavor of the image for docker sbx (Docker Sandboxes). It is published as `ghcr.io/<owner>/seth-docker-sbx` for `linux/amd64` and `linux/arm64` by `.github/workflows/build-sbx.yaml`.

- Base is `docker.io/sbx/shell-docker-image:latest` (Ubuntu, `agent` user with uid 1000 and passwordless sudo, `tini` as PID 1). The image inherits its `ENTRYPOINT`; `CMD` is `zsh` and `agent`'s login shell is the Nix `zsh`. `/bin/bash` stays installed because sbx launches the agent under `bash`.
- sbx starts its own Docker engine (base image label `com.docker.sandboxes.start-docker`). The image runs no `supervisord`, `dockerd`, `sshd`, `tailscaled`, `searxng`, `socat` or MCP daemons, and does not install `.#codespace-daemons`.
- The user toolchain is `.#sbx`: the same list as `.#default` minus `wezterm`, `buildkit` and `codebase-memory-mcp` (see `sbxExcluded` in `nix/packages.nix`). The Nix profile is `/nix/var/nix/profiles/per-user/agent/profile`, first on `PATH`.
- No `nix-daemon` runs in the sandbox, so `nix build` as `agent` needs `sudo`.
- sbx mounts the workspace itself; there is no `/workspaces` or `~/ws`.
- The sbx base image has a different user (`agent`), home (`/home/agent`) and OS release than the main image, so the two images do not share Docker layers.

## Browser Testing

The user toolchain includes `playwright-test`, with its matching Nix-packaged browsers.
Run `playwright test` directly; its wrapper supplies the browser path and Node
module search path for `@playwright/test`. No `playwright install` or system
library installation is needed. Project-local Playwright dependencies must match
the version reported by `playwright --version` to use these browser revisions.

To install only this tooling without rebuilding the full user toolchain:

```bash
nix profile install .#browser-testing
```

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
