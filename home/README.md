# Home

Home Manager user configurations live here.

Phase 1 scope:

- WSL uses Home Manager for user-level dotfiles deployment.
- Codespaces still uses the bootstrap script in the `dotfiles` repo.
- The `dotfiles` repo is a flake input to this repo, with a pinned default revision.

## Current layout

- `seth/` contains the Home Manager configuration for the `seth` user.
- Phase 1 manages these top-level items from the `dotfiles` repo:
  - `.zshenv`
  - `.profile`
  - `.luarc.json`
  - `.config/`
  - `bin/`

Directory mappings are recursive, so new files you add under `.config/` or `bin/` are picked up on the next switch.

## Local Testing Workflow

Default behavior uses the pinned `dotfiles` flake input. To test local, uncommitted changes from your working checkout before updating the pinned input, override that input with a local path.

WSL example:

```bash
cd ~/ws/nix
sudo nixos-rebuild switch --flake .#wsl \
  --override-input dotfiles path:/home/seth/ws/dotfiles
```

This lets you iterate on `/home/seth/ws/dotfiles` without committing first.

When the changes look right:

1. Commit and push the `dotfiles` repo.
2. Update the pinned `dotfiles` input in this repo.
3. Rebuild without `--override-input`.

To update the pinned `dotfiles` input:

```bash
cd ~/ws/nix
nix flake lock --update-input dotfiles
```

That refreshes `flake.lock` to the current `dotfiles` revision referenced by the flake input.

## Notes

- Home Manager only manages files you declare.
- Recursive directory mappings automatically include new files under those directories.
- Top-level files outside the declared set need a new Home Manager entry if you want them managed.
