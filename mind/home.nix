{ flake }:
{ osConfig, pkgs, ... }:

let
  name = osConfig.username;
in
{
  imports = [ flake.inputs.nixvim.homeManagerModules.nixvim ];

  # Don't change.
  home.stateVersion = "23.11";

  home.username = name;
  home.homeDirectory = "/Users/${name}";

  home.packages = with pkgs; [ 
    pinentry-curses
    termscp
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true; 

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Show full directory paths
      set fish_prompt_pwd_dir_length 0

      # Git signs
      set -g __fish_git_prompt_showcolorhints true
      set -g __fish_git_prompt_showdirtystate true
      set -g __fish_git_prompt_showuntrackedfiles true
      # Required for pinentry-curses & GPG
      set -x GPG_TTY (tty)
    '';
    shellAliases = {
      vi = "'nvim'";
      vim = "'nvim'";
    };
    functions = {
      # Disable login greeting.
      fish_greeting = {
        body = "";
      };
    };
  };

  #programs.firefox = {
  #  enable = true;
  #  profiles."default" = {
  #    isDefault = true;
  #    settings = {
  #      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  #    };
  #    userChrome = ''
  #      #TabsToolbar {
  #        visibility: collapse;
  #      }

  #      #sidebar-header {
  #        visibility: collapse !important;
  #      } 
  #    '';
  #  };
  #};

  programs.gpg = {
    enable = true;
    mutableKeys = false;
    mutableTrust = false;
  };

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
  '';

  programs.git = {
    enable = true;
    userName = osConfig.fullName;
    userEmail = osConfig.email;

    signing = {
      signByDefault = true;
      key = null;
    };
  };

  programs.ripgrep.enable = true;
  programs.lazygit = {
    enable = true;
    settings = {
      quitOnTopLevelReturn = true;
    };
  };

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.gruvbox.enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = ",";
    };

    opts = {
      number = true;
      ignorecase = true;
      background = "dark";
      shiftwidth = 4;
    };

    plugins = {
      treesitter.enable = true;
      nix.enable = true;
      conjure.enable = true;
      
      lsp = {
        enable = true;
        servers = {
	  nil-ls.enable = true;
	  clojure-lsp.enable = true;
	};
      };
    };

  };

  programs.mpv.enable = true;
}
