{pkgs}:
{
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    nixpkgs.config.allowUnfree = true;

    autoCmd = [
      {
        event = [ "BufRead" "BufNewFile" ];
        pattern = [ "*.bb" ];
        command = "set filetype=clojure";
      }
    ];

    globals = {
      mapleader = ";";
      maplocalleader = ",";
      sexp_enable_insert_mode_mappings = 0;
      "conjure#mapping#doc_word" = false;
      "conjure#client#clojure#nrepl#connection#auto_repl#cmd" = "clj -M:nrepl";
    };

    opts = {
      number = true;
      ignorecase = true;
      background = "dark";
      shiftwidth = 2;
      splitright = true;
      expandtab = true;
      smarttab = true;
    };

    highlightOverride = {
      NeoTreeGitModified = {
        fg = "#d7af5f";
      };
      NeoTreeGitAdded = {
        link = "GruvboxGreen";
      };
      NeoTreeGitStaged = {
        link = "GruvboxGreen";
      };
    };
    colorschemes.gruvbox = {
      enable = true;
      settings = {
        overrides = {
          SignColumn = { link = "GruvboxBg0"; };
          DiagnosticSignError = { link = "DiagnosticError"; };
          DiagnosticSignWarn = { link = "DiagnosticWarn"; };
          DiagnosticSignInfo = { link = "DiagnosticInfo"; };
          DiagnosticSignHint = { link = "DiagnosticHint"; };
          DiagnosticSignOk = { link = "DiagnosticOk"; };
        };
      };
    };

    # TODO: Move plugins out into their own files - allows for grouping with keymaps
    plugins = {
      claude-code = {
        enable = true;
        settings = {
          refresh = {
            enable = true;
          };
          window = {
            position = "vertical";
          };
        };
      };
      web-devicons.enable = true;
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };
      treesitter-context.enable = true;
      treesitter-refactor = {
        enable = true;
        settings = {
          highlight_definitions = {
            enable = true;
            clear_on_cursor_move = true;
          };
          highlight_current_scope = {
            enable = true;
            disable = ["nix" "typescript" "cpp"];
          };
          navigation.enable = true;
        };
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
            "<C-u>" = "cmp.mapping.scroll_docs(-4)";
            "<C-d>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = false })";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          };
        };
      };
      auto-save = {
        enable = true;
        settings = {
          debounce_delay = 150;
          write_all_buffers = true;
        };
      };

      telescope = {
        enable = true;
      };

      lazygit.enable = true;

      toggleterm.enable = true;

      dressing.enable = true;

      neo-tree = {
        enable = true;
        autoLoad = true;
        settings = {
          close_if_last_window = true;
          hide_root_node = true;

          buffers = {
            follow_current_file = {
              enabled = true;
              leave_dirs_open = false;
            };
          };

          enable_refresh_on_write = true;

          enable_git_status = true;
          git_status_async = true;

          filesystem = {
            async_directory_scan = "auto";
            follow_current_file = {
              enabled = true;
              leave_dirs_open = false;
            };
            filtered_items = {
              hide_dotfiles = false;
              hide_gitignored = false;
              visible = false;
            };
            find_command = "fd";
            find_args = {
              fd = [
                "--exclude" ".git"
                "--exclude" ".lsp"
                "--exclude" ".cargo"
                "--exclude" ".node_modules"
                "--exclude" ".clj-kondo"
                "--exclude" "target"
              ];
            };
            # use_libuv_file_watcher = true;
          };

          default_component_configs = {
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
            name = {
              use_git_status_colors = true;
            };
            git_status.symbols = {
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
      };

      nvim-autopairs = {
        enable = true;
        settings = {
          map_cr = false;
          enable_check_bracket_line = false;
        };
      };
      nvim-ufo.enable = true;

      which-key = {
        enable = true;
      };

      gitsigns.enable = true;
      lightline = {
        enable = true;
        settings = {
          colorscheme = "wombat";
          active = {
            left = [["mode" "paste"] ["readonly" "relativepath" "modified"]];
          };
        };
      };

      notify = {
        enable = true;
        settings.fps = 60;
      };

      todo-comments = {
        enable = true;
        settings.signs = false;
      };

      nix.enable = true;
      conjure.enable = true;
      zig.enable = true;

      rustaceanvim.enable = true;
      dap.enable = true;
      dap-ui.enable = true;

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
          clojure_lsp.enable = true;
          gopls.enable = true;
          nixd.enable = true;
          protols.enable = true;
          ts_ls.enable = true;
          svelte.enable = true;
          tailwindcss.enable = true;
          html.enable = true;
          starpls = {
            enable = true;
            autostart = true;
            cmd = ["starpls" "server" "--bazel_path" "${pkgs.bazelisk}/bin/bazelisk"];
            filetypes = [ "bzl" "bazel" ];
            rootMarkers = [ "WORKSPACE" "WORKSPACE.bzl" "WORKSPACE.bazel" "MODULE" "MODULE.bzl" "MODULE.bazel"];
          };
          java_language_server.enable = true;
          jsonnet_ls.enable = true;
          jsonls.enable = true;
          eslint.enable = true;
        };
      };

      lsp-lines = {
        enable = true;
        autoLoad = true;
      };

      lsp-format = {
        enable = true;
        autoLoad = true;
        lspServersToEnable = "all";
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
        mode = ["n" "t" "v"];
        action = "<cmd>1tabnext<CR>";
        key = "<C-1>";
      }
      {
        mode = ["n" "t" "v"];
        action = "<cmd>2tabnext<CR>";
        key = "<C-2>";
      }
      {
        mode = ["n" "t" "v"];
        action = "<cmd>3tabnext<CR>";
        key = "<C-3>";
      }
      {
        mode = ["n" "t" "v"];
        action = "<cmd>4tabnext<CR>";
        key = "<C-4>";
      }
      {
        mode = ["n"];
        action = "<cmd>Telescope find_files<CR>";
        key = "<S-C-f>";
      }
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
        action = "<cmd>ToggleTerm direction=float<CR>";
        key = "<C-'>";
      }
      {
        mode = ["n" "t"];
        action = "<cmd>lua _lazygit_toggle()<CR>";
        key = "<C-g>";
      }
      {
        mode = ["n"];
        action = "<cmd>Gitsigns preview_hunk_inline<CR>";
        key = "<leader>hp";
      }
      {
        mode = ["n"];
        action = "<cmd>Gitsigns toggle_deleted<CR><cmd>Gitsigns toggle_linehl<CR><cmd>Gitsigns toggle_numhl<CR><cmd>Gitsigns toggle_word_diff<CR>";
        key = "<C-p>";
      }
      {
        mode = ["n"];
        action = "<cmd>lua vim.diagnostic.open_float(0, {scope='line'})<CR>";
        key = "<leader>e";
      }
      {
        mode = ["n"];
        action = "<cmd>lua vim.lsp.buf.rename()<CR>";
        key = "<leader>lr";
      }
      {
        mode = ["n"];
        action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
        key = "<leader>la";
      }
      {
        mode = ["i" "n"];
        action = "<cmd>lua vim.lsp.buf.signature_help()<CR>";
        key = "<C-S>";
      }
      {
        mode = ["n"];
        action = "<cmd>lua require('dapui').toggle()<CR>";
        key = "<leader>du";
      }
      {
        mode = ["n"];
        action = "<cmd>lua require('dap').toggle_breakpoint()<CR>";
        key = "<leader>db";
      }
      {
        mode = ["n"];
        action = "<cmd>lua require('dap').repl.open()<CR>";
        key = "<leader>dr";
      }
      {
        mode = ["n"];
        action = "<cmd>RustLsp debug<CR>";
        key = "<leader>rD";
      }
      {
        mode = ["n"];
        action = "<cmd>RustLsp debuggables<CR>";
        key = "<leader>rd";
      }
      {
        mode = ["n"];
        action = "<cmd>RustLsp openDocs<CR>";
        key = "<leader>ro";
      }
      {
        mode = ["i" "n"];
        action = "<Plug>(easymotion-s)";
        key = "<C-Q>";
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
      {
        mode = ["n"];
        action = "<cmd>ClaudeCode<CR>";
        key = "<C-c>";
      }
    ];

    extraPlugins = with pkgs.vimPlugins; [
      vim-surround
      vim-sexp
      vim-sexp-mappings-for-regular-people
      vim-easymotion
      playground # treesitter-playground
      nvim-nio
    ];

    extraConfigLua = ''
      -- clojure_lsp
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      vim.lsp.config['clojure_lsp'] = {
        capabilities = capabilities
      }

      -- lsp-format
      require("lsp-format").setup {}
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
          require("lsp-format").on_attach(client, args.buf)
        end,
      })

      -- lsp-lines
      vim.diagnostic.config({virtual_lines = true})

      -- lazygit
      local Terminal = require('toggleterm.terminal').Terminal
      local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float"})
      function _lazygit_toggle()
        lazygit:toggle()
      end

      -- dap
      vim.fn.sign_define('DapBreakpoint', {
        text='*',
        texthl='DapBreakpointSymbol',
        linehl='DapBreakpointSymbol',
        numhl='DapBreakpointSymbol'
      })

      -- ties neovim default clipboard to system clipboard
      vim.api.nvim_set_option("clipboard", "unnamed")

      -- start with no folds
      vim.o.foldlevelstart = 99

      -- inlay hints
      vim.lsp.inlay_hint.enable(true)
    '';
}
