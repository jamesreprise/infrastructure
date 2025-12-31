{ flake, nixvim }:
{ osConfig, pkgs, ... }:

let
  name = osConfig.username;
in
{
  imports = [ flake.inputs.nixvim.homeModules.nixvim ];

  # Don't change.
  home.stateVersion = "23.11";

  home.username = name;
  home.homeDirectory = "/Users/${name}";

  home.packages = with pkgs; [
    # Development
    babashka
    bazelisk
    bun
    clj-kondo
    cljfmt
    clojure
    devenv
    evcxr
    nodejs_24
    pinentry-curses
    podman
    pre-commit
    protobuf
    rlwrap
    rustup
    zulu24

    # Tools
    age
    atuin
    nmap
    magic-wormhole
    mediainfo
    texliveFull
    inetutils
    websocat
    socat
    fd
    mkcert
    nss_latest
    qemu
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true; 

  # WARN: we manually provide the same JDK clojure is using without enforcing
  #       it at a code level (perhaps via overrides?), which we ought to.
  home.file.".config/clojure-lsp/config.edn".text = ''
  {:dependency-scheme "zipfile"
   :java {:jdk-source-uri "file://${pkgs.zulu24}/lib/src.zip"}}
  '';

  home.file.".hushlogin".text = "";

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

      # Add cargo binaries to path
      fish_add_path ~/.cargo/bin
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
  };

  programs.direnv.enable = true;

  programs.gpg = {
    enable = true;
    mutableKeys = false;
    mutableTrust = false;
    settings = {
      pinentry-mode = "loopback";
    };
  };

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
    allow-loopback-pinentry
  '';

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = osConfig.fullName;
        email = osConfig.email;
      };
    };
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

  programs.nixvim = nixvim { pkgs = pkgs; };
}
