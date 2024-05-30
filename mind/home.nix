{ pkgs, osConfig, ... }:

let
  name = osConfig.username;
in
{
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

  programs.gpg = {
    enable = true;
    mutableKeys = false;
    mutableTrust = false;
  };

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
  '';

  # TODO: Move config up into flake.
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

  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    defaultEditor = true;
    
    extraConfig = ''
      set ignorecase
      set background=dark
      set number
      set mouse=a
      set tabstop=4
      set shiftwidth=4
      set softtabstop=4
      set expandtab
      set hidden
      set wrap
      set t_Co=256
      
      let mapleader = ","
      let maplocalleader = ","
    '';

    plugins = with pkgs.vimPlugins; [
      { 
        plugin = gruvbox-nvim;
        type = "lua";
        config = '' 
          require('gruvbox').setup({
            overrides = {
              SignColumn = {bg = "#282828"}
            }
          })
          vim.cmd("colorscheme gruvbox")
        ''; 
      }

      plenary-nvim
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
          vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
          vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
          vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        '';
      }
      {
        plugin = toggleterm-nvim;
        type = "lua";
        config = ''
          require('toggleterm').setup()
        '';
      }
      { 
        plugin = autosave-nvim;
        type = "lua";
        config = ''
          require('autosave').setup({})
        '';
      }
      { 
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require('gitsigns').setup()
        '';
      }
      {
        plugin = lazygit-nvim;
        type = "lua";
        config = ''
          vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<CR>')
        '';
      }
      mason-nvim
      mason-lspconfig-nvim
      nvim-lspconfig
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          require('nvim-treesitter.configs').setup({
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            }
          })
        '';
      }
      playground
      nvim-treesitter-textobjects

      nerdtree
      nerdtree-git-plugin

      vim-airline
      vim-airline-themes
      vim-nix
      vim-fugitive
    ];   
  };

  programs.mpv.enable = true;
}
