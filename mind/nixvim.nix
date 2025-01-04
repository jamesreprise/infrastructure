{pkgs}:
{
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    globals = {
      mapleader = ";";
      maplocalleader = ",";
      sexp_enable_insert_mode_mappings = 0;
    };

    opts = {
      number = true;
      ignorecase = true;
      background = "dark";
      shiftwidth = 4;
      splitright = true;
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
      web-devicons.enable = true;
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
      auto-save = {
        enable = true;
        settings = {
          debounce_delay = 25;
          write_all_buffers = true;
        };
      };

      telescope = {
        enable = true;
      };

      lazygit.enable = true;
      toggleterm.enable = true;

      neo-tree = {
        enable = true;
        closeIfLastWindow = true;
        hideRootNode = true;

        filesystem.filteredItems = {
          hideDotfiles = false;
          hideGitignored = true;
          visible = true;
        };

        defaultComponentConfigs = {
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
      };

      nvim-autopairs = {
        enable = true;
        settings = {
          map_cr = false;
        };
      };
      nvim-ufo.enable = true;

      which-key = {
        enable = true;
      };

      gitsigns.enable = true;
      lightline = {
        enable = true;
        settings.colorscheme = "wombat";
      };

      notify = {
        enable = true;
        fps = 60;
      };

      todo-comments = {
        enable = true;
        settings.signs = false;
      };

      nix.enable = true;
      conjure.enable = true;
      zig.enable = true;

      lsp = {
        enable = true;
        keymaps = {
          lspBuf = {
            K = "hover";
            gD = "references";
            gd = "definition";
            gi = "implementation";
            gt = "type_definition";
          };
        };
        servers = {
          nil_ls.enable = true;
          clojure_lsp.enable = true;
          protols.enable = true;
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
        action = "<cmd>Telescope live_grep<CR>";
        key = "<C-f>";
      }
      {
        mode = ["n"];
        action = "<cmd>Telescope<CR>";
        key = "<C-t>";
      }
      {
        mode = ["n"];
        action = "<cmd>Neotree toggle<CR>";
        key = "<C-e>";
      }
      {
        mode = ["n" "t"];
        action = "<cmd>ToggleTerm<CR>";
        key = "<C-'>";
      }
      {
        mode = ["n" "t"];
        action = "<cmd>lua _lazygit_toggle()<CR>";
        key = "<C-g>";
      }
      {
        mode = ["n"];
        action = "<cmd>lua vim.diagnostic.open_float(0, {scope='line'})<CR>";
        key = "<leader>e";
      }
      {
        mode = ["n"];
        action = "<C-w>h";
        key = "<C-h>";
      }
      {
        mode = ["n"];
        action = "<C-w>j";
        key = "<C-j>";
      }
      {
        mode = ["n"];
        action = "<C-w>k";
        key = "<C-k>";
      }
      {
        mode = ["n"];
        action = "<C-w>l";
        key = "<C-l>";
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
      -- clojure_lsp
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      require('lspconfig')['clojure_lsp'].setup {
        capabilities = capabilities
      }

      -- lazygit
      local Terminal = require('toggleterm.terminal').Terminal
      local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float"})
      function _lazygit_toggle()
        lazygit:toggle()
      end

      -- ties neovim default clipboard to system clipboard
      vim.api.nvim_set_option("clipboard","unnamed")

      -- start with no folds
      vim.o.foldlevelstart = 99
    '';
}
