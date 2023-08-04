{ config, lib, pkgs, ... }:
let

  bazel_sym_link = pkgs.writeScriptBin "bazel" ''
    #!${pkgs.stdenv.shell}
    unset CC CXX
    exec ${pkgs.bazelisk}/bin/bazelisk "$@"
  '';
  
  scripts = [ bazel_sym_link ];

  temurin_x86_64 = pkgs.temurin-bin-11.overrideAttrs (finalAttrs: previousAttrs: { 
    src = builtins.fetchurl { 
      url = "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.17%2B8/OpenJDK11U-jdk_x64_mac_hotspot_11.0.17_8.tar.gz";
      sha256 = "f408a12f10d93b3205bef851af62707531b699963cef79408d59197d08763c94"; 
    };
  });

in 
{
  home.packages = with pkgs; [
    # Networking
    bind magic-wormhole nmap mtr
    # Sysadmin
    ncdu htop tmux ripgrep jq upx
    # Cryptography
    certbot pinentry-curses gnupg mkcert nss cfssl
    # Git/VCS
    tig gh
    # Cloud
    k9s terraform docker docker-machine argocd kubernetes-helm
    awscli2 (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ]) 
    cmctl
    # Build systems
    bazelisk bazel-buildtools gradle maven hatch rustup
    # JS
    nodejs_20 nodePackages_latest.pnpm
    nodePackages."@angular/cli"
    # Clojure
    clojure babashka
    # LaTeX
    (texlive.combine {
      inherit (texlive) scheme-full kpfonts fontspec titlesec enumitem changepage;
    })
    mpv
  ] ++ scripts;

  home.sessionVariables = {
    JAVA_HOME = "${temurin_x86_64}/Contents/Home";
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
    extraConfig = builtins.readFile ./vimrc;
  };
}
