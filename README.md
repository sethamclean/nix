# Nix Workspace

This repo drives two different targets:

- `nixosConfigurations.wsl` for the WSL host.
- Flake packages for the Codespaces image and user toolchain.

## Update Matrix

| Target | Source of truth | How to apply |
| --- | --- | --- |
| WSL system packages | `hosts/wsl/default.nix`, `nix/packages.nix` | `sudo nixos-rebuild switch --flake .#wsl` |
| Codespaces root daemons | `.#codespace-daemons` | Rebuild the Docker image |
| Codespaces user tools | `.#default` | Rebuild the Docker image, or run `nix profile upgrade nix` from `~/ws/nix` |
| Image OS packages | `docker/Dockerfile` apt steps | Rebuild the Docker image |

## Codespaces Notes

- `seth` is the interactive user and gets the `.#default` Nix profile.
- Root-run services use the root Nix profile populated from `.#codespace-daemons`.
- `sudo` is installed in the image and `seth` has passwordless sudo for container admin tasks.
- `~/ws` is the canonical workspace path. In Codespaces it points at `/workspaces`.

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
