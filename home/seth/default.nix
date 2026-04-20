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
    ".profile".source = dotfiles + "/.profile";
    ".luarc.json".source = dotfiles + "/.luarc.json";
    "bin" = {
      source = dotfiles + "/bin";
      recursive = true;
    };
    ".config" = {
      source = dotfiles + "/.config";
      recursive = true;
    };
  };

  programs.home-manager.enable = true;
}
