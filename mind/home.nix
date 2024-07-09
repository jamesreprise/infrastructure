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
    clj-kondo
    clojure
    zulu
    bazelisk
    pre-commit
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true; 

  # WARN: we manually provide the same JDK clojure is using without enforcing
  #       it at a code level (perhaps via overrides?), which we ought to.
  home.file.".config/clojure-lsp/config.edn".text = ''
  {:dependency-scheme "jar"
   :java {:jdk-source-uri "file://${pkgs.zulu}/zulu-21.jdk/Contents/Home/lib/src.zip"}}
  '';

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
      bazel = "'bazelisk'";
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
      mapleader = ";";
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

    # TODO: Move plugins out into their own files - allows for grouping with keymaps
    plugins = {
      treesitter.enable = true;
      treesitter-context.enable = true;
      treesitter-refactor = {
        enable = true;
        highlightDefinitions = {
          enable = true;
          clearOnCursorMove = true;
        };
        highlightCurrentScope = {
          enable = true;
          disable = ["nix"];
        };
        navigation.enable = true;
      };
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp_luasnip.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-nvim-lsp-signature-help.enable = true;
      cmp-nvim-lua.enable = true;
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
          ];
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-u>" = "cmp.mapping.scroll_docs(-4)";
            "<C-d>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          };
        };
      };
      auto-save.enable = true;

      telescope = {
        enable = true;
        settings = {
          pickers.find_files.disable_devicons = true;
        };
      };

      lazygit.enable = true;
      toggleterm.enable = true;
      neo-tree = {
        enable = true;
        closeIfLastWindow = true;
        hideRootNode = true;

        defaultComponentConfigs = {
          icon = {
            folderClosed = ">";
            folderEmpty = "≥";
            folderOpen = "v";
            folderEmptyOpen = "v";
          };
          diagnostics = {
            symbols = {
              hint = "H";
              info = "I";
              warn = "!";
              error = "X";
            };
            highlights = {
              hint = "DiagnosticSignHint";
              info = "DiagnosticSignInfo";
              warn = "DiagnosticSignWarn";
              error = "DiagnosticSignError";
            };
          };
          gitStatus.symbols = {
            added = "+";
            deleted = "-";
            modified = "~";
            conflict = "x";
            renamed = "r";
            untracked = "U";
            ignored = "i";
            unstaged = "u";
            staged = "s";
          };
        };

        renderers = {
          directory = [ 
            "indent"
            "icon"
            "current_filter"
            {
              name = "container";
              content = [
                { name = "name"; zindex = 10; }
                { name = "clipboard"; zindex = 10; }
                { name = "diagnostics"; errors_only = true; zindex = 20; align = "right"; hide_when_expanded = true; }
                { name = "git_status"; zindex = 20; align = "right"; hide_when_expanded = true; }
              ];
            }
          ];
          file = [
            "indent"
            {
              name = "container";
              content = [
                { name = "name"; zindex = 10; }
                { name = "clipboard"; zindex = 10; }
                { name = "bufnr"; zindex = 10; }
                { name = "modified"; zindex = 20; align = "right"; }
                { name = "diagnostics"; zindex = 20; align = "right"; }
                { name = "git_status"; zindex = 20; align = "right"; }
              ];
            }
          ];
          terminal = [ "indent" "name" "bufnr" ];
        };
      };

      which-key = {
        enable = true;
        triggers = "auto";
      };
      gitsigns.enable = true;
      lightline = {
        enable = true;
        colorscheme = "wombat";
      };

      notify = {
        enable = true;
        fps = 60;
        icons = {
          debug = "D";
          error = "E";
          info = "I";
          trace = "T";
          warn = "W";
        };
      };

      todo-comments = {
        enable = true;
        signs = false;
      };

      nix.enable = true;
      conjure.enable = true;
      zig.enable = true;

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
      vim-easymotion
      playground # treesitter-playground
    ];

    extraConfigLua = ''
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      require('lspconfig')['clojure_lsp'].setup {
        capabilities = capabilities
      }
    '';
  };

  programs.mpv.enable = true;
}
