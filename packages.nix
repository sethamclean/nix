{ pkgs }: {
  daemons = [ pkgs.python311Packages.supervisor pkgs.docker ];
  cli = [
    pkgs.zsh
    pkgs.neovim
    pkgs.tmux
    pkgs.git
    pkgs.gh
    pkgs.man
    pkgs.tealdeer
    pkgs.bottom
    pkgs.procs
    pkgs.curl
    pkgs.xh
    pkgs.traceroute
    pkgs.iproute2
    pkgs.gzip
    pkgs.zip
    pkgs.unzip
    pkgs.less
    # Base-devel? https://archlinux.org/packages/core/any/base-devel/
    pkgs.gcc
    pkgs.clang-tools
    pkgs.cmake
    pkgs.gnumake
    # end base-deel
    pkgs.bind
    pkgs.rustup
    pkgs.ripgrep
    pkgs.fzf
    pkgs.bat
    pkgs.fd
    pkgs.eza
    pkgs.zoxide
    pkgs.stow
    pkgs.parallel
    pkgs.buildkit
    pkgs.stylua
    pkgs.nodePackages.prettier
    pkgs.shellcheck
    pkgs.go
    pkgs.gopls
    pkgs.delve
    pkgs.parallel
    pkgs.pyenv
    pkgs.poetry
    pkgs.pipenv
    pkgs.pre-commit
    pkgs.ruff
    pkgs.shfmt
    pkgs.nodePackages.npm
    pkgs.ruby
    pkgs.kubectl
    pkgs.eksctl
    pkgs.helm
    pkgs.vault
    pkgs.tree
    pkgs.jq
    pkgs.tailscale
    pkgs.awscli2
    pkgs.nodejs
    pkgs.yarn
    pkgs.google-cloud-sdk
    pkgs.jfrog-cli
    pkgs.act
    pkgs.terraform-docs
    pkgs.tfsec
    pkgs.tflint
    pkgs.github-release
    pkgs.golangci-lint
    pkgs.cve-bin-tool
    (pkgs.python3.withPackages (
     python-pkgs: [
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
     ])
    )
    pkgs.lefthook
    pkgs.nixfmt
    pkgs.ast-grep
    # pyenv-virtualenv?
    # tfenv
  ];
}
