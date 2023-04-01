{ config, lib, pkgs, ... }:
{
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
        theme = "minimal";
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
}
