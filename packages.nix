{ pkgs }:
{
 Pkgs = [
    pkgs.nixStatic
    pkgs.man
    pkgs.tealdeer
    pkgs.python311Packages.supervisor
    pkgs.bottom
    # Base-devel? https://archlinux.org/packages/core/any/base-devel/
    pkgs.gzip
    # end base-deel
    pkgs.zsh
    pkgs.git
    pkgs.less
    pkgs.openssh
    pkgs.bind
    pkgs.zip
    pkgs.unzip
    pkgs.rustup
    pkgs.ripgrep
    pkgs.fzf
    pkgs.eza
    pkgs.zoxide
    pkgs.stow
    pkgs.parallel
    pkgs.docker
    pkgs.neovim
    pkgs.stylua
    pkgs.nodePackages.prettier
    pkgs.shellcheck
    pkgs.python311Packages.pynvim
    pkgs.go
    pkgs.gopls
    pkgs.delve
    pkgs.parallel
    pkgs.pyenv
    pkgs.python311Packages.pip
    pkgs.pipenv
    pkgs.poetry
    pkgs.python311Packages.python-lsp-server
    pkgs.pre-commit
    pkgs.ruff
    pkgs.python311Packages.debugpy
    pkgs.python311Packages.pytest
    pkgs.python311Packages.pylint
    pkgs.mypy
    pkgs.python311Packages.flake8
    pkgs.shfmt
    pkgs.nodePackages.npm
    pkgs.ruby
    pkgs.kubectl
    pkgs.eksctl
    pkgs.helm
    pkgs.vault
    pkgs.tree
    pkgs.tmux
    pkgs.jq
    pkgs.tailscale
    pkgs.gh
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
    pkgs.rustc
    # pyenv-virtualenv?
    # tfenv
  ];
}
