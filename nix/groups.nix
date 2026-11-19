{ pkgs }:
let
  custom = import ./pkgs { inherit pkgs; };
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  # Shell, editor, VCS and everyday command-line tools.
  core = [
    pkgs.zsh
    pkgs.neovim
    pkgs.tree-sitter
    pkgs.tmux
    pkgs.sesh
    pkgs.direnv
    pkgs.nixfmt
    pkgs.git
    pkgs.delta
    pkgs.jujutsu
    pkgs.jjui
    pkgs.gh
    pkgs.gnupg
    pkgs.pass
    pkgs.pinentry-curses
    pkgs.man
    pkgs.tealdeer
    pkgs.bottom
    pkgs.procs
    pkgs.curl
    pkgs.xh
    pkgs.netcat
    pkgs.wget
    pkgs.gzip
    pkgs.zip
    pkgs.unzip
    pkgs.rsync
    pkgs.less
    pkgs.util-linux
    pkgs.file
    pkgs.ripgrep
    pkgs.fzf
    pkgs.bat
    pkgs.fd
    pkgs.eza
    pkgs.zoxide
    pkgs.stow
    pkgs.parallel
    pkgs.tree
    pkgs.jq
    pkgs.yq-go
    pkgs.bind
    pkgs.lefthook
    pkgs.pre-commit
    pkgs.ast-grep
    pkgs.shellcheck
    pkgs.shfmt
    pkgs.stylua
    pkgs.prettier
    pkgs.markdownlint-cli
    pkgs.yamllint
  ]
  ++ pkgs.lib.optionals isLinux [
    pkgs.traceroute
    pkgs.iproute2
  ];

  # AI coding agents and their helpers.
  ai = [
    pkgs.opencode
    pkgs.claude-code
    pkgs.codebase-memory-mcp
    pkgs.workmux
    pkgs.openshell
    pkgs.box
  ];

  # Compilers and the build tools Yocto expects.
  build = [
    pkgs.gcc
    pkgs.clang-tools
    pkgs.cmake
    pkgs.gnumake
    pkgs.pkg-config
    pkgs.gnutar
    pkgs.zstd
    pkgs.bzip2
    pkgs.xz
    pkgs.patch
    pkgs.diffstat
    pkgs.cpio
    pkgs.gawk
    pkgs.perl
  ]
  ++ pkgs.lib.optionals isLinux [ pkgs.chrpath ];

  # Language toolchains, language servers and per-language tooling.
  lang = [
    pkgs.devbox
    pkgs.rustup
    pkgs.go
    pkgs.gopls
    pkgs.delve
    pkgs.golangci-lint
    pkgs.pyenv
    pkgs.poetry
    pkgs.pipenv
    pkgs.ruff
    pkgs.ty
    pkgs.uv
    pkgs.bun
    pkgs.ruby
    pkgs.nodejs
    pkgs.yarn
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.python-lsp-server
      python-pkgs.pip
      python-pkgs.pipx
      python-pkgs.mypy
      python-pkgs.pynvim
      python-pkgs.debugpy
      python-pkgs.pytest
      python-pkgs.pylint
      python-pkgs.flake8
      python-pkgs.ujson
    ]))
    pkgs.mariadb
    pkgs.hugo
    pkgs.plantuml
    pkgs.mermaid-cli
    custom.browser-testing
  ];

  # Kubernetes, cloud, Terraform and supply-chain tooling.
  cloud = [
    pkgs.docker-credential-helpers
    pkgs.buildkit
    pkgs.kubectl
    pkgs.eksctl
    pkgs.kubernetes-helm
    pkgs.k9s
    pkgs.kustomize
    pkgs.oras
    pkgs.fluxcd
    pkgs.kubeconform
    pkgs.kind
    pkgs.vault
    pkgs.awscli2
    pkgs.google-cloud-sdk
    pkgs.jfrog-cli
    pkgs.act
    pkgs.terraform-ls
    pkgs.terraform-docs
    pkgs.tfsec
    pkgs.tflint
    pkgs.terraformer
    pkgs.infracost
    pkgs.tenv
    pkgs.github-release
    pkgs.appfire-cli
    pkgs.syft
    pkgs.grype
  ];

  # Desktop applications that need a display.
  # nixpkgs builds ghostty from source on Linux only; macOS gets the prebuilt app.
  gui = [ (if isLinux then pkgs.ghostty else pkgs.ghostty-bin) ];

  # Long-lived services for the codespace container. NixOS hosts configure
  # these through services.* options instead.
  daemons = [
    pkgs.python311Packages.supervisor
    pkgs.docker
    pkgs.socat
    pkgs.tailscale
  ];
}
