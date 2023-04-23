{ config, lib, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    initExtraFirst = builtins.readFile ./zshrc;
    initExtra = ''
    export OPENSSL_DIR="${pkgs.openssl.dev}"
    export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
    '';
    prezto = {
      enable = true;
      pmodules = [
        "editor"
        "history"
        "completion"
        "prompt"
        "autosuggestions"
      ];
      prompt = {
        theme = "minimal";
        pwdLength = "full";
        showReturnVal = true;
      };
    };
  };

  programs.starship = {
    enable = true;
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
