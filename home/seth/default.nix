{
  dotfiles,
  userName,
  ...
}:
{
  home.username = userName;
  home.homeDirectory = "/home/${userName}";
  home.stateVersion = "25.05";

  home.file = {
    ".zshenv".source = dotfiles + "/.zshenv";
    ".luarc.json".source = dotfiles + "/.luarc.json";
    "bin" = {
      source = dotfiles + "/bin";
      recursive = true;
    };
    ".config/bottom" = {
      source = dotfiles + "/.config/bottom";
      recursive = true;
    };
    ".config/fd" = {
      source = dotfiles + "/.config/fd";
      recursive = true;
    };
    ".config/git" = {
      source = dotfiles + "/.config/git";
      recursive = true;
    };
    ".config/k9s" = {
      source = dotfiles + "/.config/k9s";
      recursive = true;
    };
    ".config/kind" = {
      source = dotfiles + "/.config/kind";
      recursive = true;
    };
    ".config/nvim" = {
      source = dotfiles + "/.config/nvim";
      recursive = true;
    };
    ".config/opencode" = {
      source = dotfiles + "/.config/opencode";
      recursive = true;
    };
    ".config/ruff" = {
      source = dotfiles + "/.config/ruff";
      recursive = true;
    };
    ".config/tmux" = {
      source = dotfiles + "/.config/tmux";
      recursive = true;
    };
    ".config/ty" = {
      source = dotfiles + "/.config/ty";
      recursive = true;
    };
    ".config/wezterm" = {
      source = dotfiles + "/.config/wezterm";
      recursive = true;
    };
    ".config/zsh" = {
      source = dotfiles + "/.config/zsh";
      recursive = true;
    };
  };

  programs.home-manager.enable = true;
}
