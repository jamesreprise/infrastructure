{ config, lib, pkgs, ... }: {
  home.username = "james";
  home.homeDirectory = "...";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;
  programs.home-manager.path = "...";

  home.packages = with pkgs; [ bind ripgrep tig ];

  programs.git = {
    enable = true;
    includes = [{ path = "~/.config/nixpkgs/gitconfig"; }];
    diff-so-fancy.enable = true;
  };

  programs.zsh = {
    enable = true;
    initExtra = builtins.readFile ./zshrc;
    prezto = {
      enable = true;
      pmodules = [
        "environment"
        "terminal"
        "editor"
        "history"
        "directory"
        "spectrum"
        "utility"
        "completion"
        "prompt"
        "history-substring-search"
        "autosuggestions"
        "git"
      ];
      prompt = {
        theme = "redhat";
        pwdLength = "full";
        showReturnVal = true;
      };
    };
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files --hidden";
  };

  programs.zoxide = {
    enable = true;
  };

  programs.exa = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = builtins.readFile ./vimrc;
  };
}