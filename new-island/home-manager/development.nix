{ config, lib, pkgs, ... }:
let

  bazel_sym_link = pkgs.writeScriptBin "bazel" ''
    #!${pkgs.stdenv.shell}
    unset CC CXX
    exec ${pkgs.bazelisk}/bin/bazelisk "$@"
  '';
  
  scripts = [ bazel_sym_link ];

in 
{
  home.packages = with pkgs; [
    # Networking
    bind magic-wormhole nmap mtr websocat
    # Sysadmin
    ncdu htop tmux ripgrep jq upx diffoscopeMinimal
    # Cryptography
    certbot-full pinentry-curses gnupg mkcert nss cfssl
    # Git/VCS
    tig gh
    # Cloud
    kubectl k9s terraform docker docker-machine argocd kubernetes-helm
    awscli2 (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ]) azure-cli
    gcsfuse
    nodePackages_latest.firebase-tools
    cmctl 
    minikube
    kubeconform
    # Protobuf
    protobuf
    # Build systems
    bazelisk bazel-buildtools gradle maven hatch rustup
    # Java
    jdk17
    # JS
    nodejs_20 nodePackages_latest.pnpm
    nodePackages."@angular/cli"
    # Clojure
    clojure babashka clj-kondo joker
    # Python
    python310Full
    # LaTeX
    (texlive.combine {
      inherit (texlive) scheme-full kpfonts fontspec titlesec enumitem changepage;
    })
    # Go
    go gopls
    # Misc  
    file mpv imagemagick
  ] ++ scripts;

  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk17}";
  };

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses";
  '';

  programs.git = {
    enable = true;
    includes = [{ path = "~/.config/home-manager/gitconfig"; }];
    diff-so-fancy.enable = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
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
      set t_Co=256
      nnoremap <Space> i
      inoremap <S-Space> <Esc>

      set omnifunc=syntaxcomplete#Complete

      colorscheme gruvbox

      let mapleader = "," 
      let maplocalleader = ","

      nnoremap <leader>n :NERDTreeFocus<CR>
      nnoremap <C-n> :NERDTreeToggle<CR>

      let g:float_preview#docked = 0
      let g:float_preview#max_width = 80
      let g:float_preview#max_height = 40

      highlight NormalFloat ctermbg=black guibg=black

      let g:deoplete#enable_at_startup = 1
      call deoplete#custom#option('keyword_patterns', {'clojure': '[\w!$%&*+/:<=>?@\^_~\-\.#]*'})
      set completeopt-=preview

      let g:ale_linters = { 'clojure': ['clj-kondo', 'joker'] }
    '';

    extraLuaConfig = ''
      vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    '';
    
    plugins = with pkgs.vimPlugins; [
      # General
      vim-airline
      {
        plugin = toggleterm-nvim;
        type = "lua";
        config = ''
          require("toggleterm").setup({
            open_mapping = [[<leader>q]],
            start_in_insert = true,
            direction = "float",
          })
        '';
      }
      gruvbox
      nerdtree
      fzf-vim
      deoplete-nvim
      float-preview-nvim
      vim-easymotion
      {
        plugin = conform-nvim;
        type = "lua";
        config = ''
        require("conform").setup({
          formatters_by_ft = {
            clojure = { "joker" },
          },
          format_on_save = {
            timeout_ms = 500,
            lsp_fallback = false,
          },
        })
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*",
          callback = function(args)
            require("conform").format({ bufnr = args.buf})
          end,
        })
        '';
      }
      # Clojure
      ale
      vim-dispatch vim-jack-in conjure
      vim-repeat vim-surround vim-sexp vim-sexp-mappings-for-regular-people
      # Go
      vim-go
    ];
  };
}
