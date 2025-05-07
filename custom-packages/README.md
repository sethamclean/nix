# Custom Packages for GitHub Binary Releases

This directory contains custom Nix derivations for GitHub binary releases.

## Available Packages

### code2prompt

- Version: 3.0.2
- Description: Generate prompts from your code for AI programming assistants like ChatGPT and Claude
- Homepage: https://github.com/mufeedvh/code2prompt

## Adding New GitHub Binary Releases

To add a new binary release from GitHub:

1. Create a new Nix file with the package name (e.g., `package-name.nix`)
2. Use the template in `github-binaries.nix` as a guide
3. Import your new package in `default.nix`

## Function Reference

The `mkGitHubBinaryDerivation` function in `github-binaries.nix` allows you to easily create
packages from GitHub binary releases with minimal boilerplate.

Example:

```nix
mkGitHubBinaryDerivation {
  pname = "tool-name";
  version = "1.0.0";
  filename = "tool-name-linux-amd64";
  sha256 = "..."; # Get this with: nix-prefetch-url https://github.com/author/repo/releases/download/vX.Y.Z/filename
  description = "Description of the tool";
  homepage = "author/repo";
}
```
