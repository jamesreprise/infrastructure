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
    plugins = [
      {
        name = "base16-fish";
        src = pkgs.fetchFromGitHub {
          owner = "tomyun";
          repo = "base16-fish";
          rev = "2f6dd97";
          sha256 = "PebymhVYbL8trDVVXxCvZgc0S5VxI7I1Hv4RMSquTpA=";
        };
      }
      {
        name = "z-fish";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "85f863f";
          sha256 = "+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
        };
      }
    ];
    interactiveShellInit = ''
      # Gruvbox theme
      base16-gruvbox-dark-medium

      # Gold user and cwd
      set fish_color_cwd yellow
      set fish_color_user yellow

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
      ls = "'eza'";
    };
    functions = {
      # Disable login greeting.
      fish_greeting = {
        body = "";
      };
    };
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = false;
  };

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

    globals = {
      mapleader = ",";
      maplocalleader = ",";
    };

    opts = {
      number = true;
      ignorecase = true;
      background = "dark";
      shiftwidth = 4;
    };

    colorschemes.gruvbox = {
      enable = true;
      settings = {
        overrides = {
          SignColumn = { bg = "#282828"; };
        };
      };
    };

    plugins = {
      treesitter.enable = true;
      auto-save.enable = true;

      telescope.enable = true;
      lazygit.enable = true;
      toggleterm.enable = true;
      neo-tree = {
        enable = true;
        closeIfLastWindow = true;
        hideRootNode = true;

        defaultComponentConfigs = {
          icon = {
            default = "*";
            folderClosed = ">";
            folderEmpty = "≥";
            folderOpen = "v";
          };
        };
      };

      which-key.enable = true;
      gitsigns.enable = true;
      lightline = {
        enable = true;
        colorscheme = "wombat";
      };

      notify.enable = true;

      todo-comments.enable = true;

      nix.enable = true;
      conjure.enable = true;

      lsp = {
        enable = true;
        servers = {
	  nil-ls.enable = true;
	  clojure-lsp.enable = true;
	};
      };

      lint = { 
        enable = true;
        lintersByFt = {
          clojure = [ "clj-kondo" ];
        };
      };
    };

    keymaps = [
      {
        mode = ["n"];
        action = "<cmd>Telescope<CR>";
        key = "<C-f>";
      }
      {
        mode = ["n"];
        action = "<cmd>Neotree<CR>";
        key = "<C-e>";
      }
      {
        mode = ["n" "t"];
        action = "<cmd>ToggleTerm<CR>";
        key = "<C-q>";
      }
    ];

    extraPlugins = with pkgs.vimPlugins; [
      vim-surround
      vim-sexp
      vim-sexp-mappings-for-regular-people
    ];
  };

  programs.mpv.enable = true;
}
