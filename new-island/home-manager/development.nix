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
    minikube
    # Build systems
    bazelisk bazel-buildtools gradle maven hatch rustup
    # Java
    jdk17
    # JS
    nodejs_20 nodePackages_latest.pnpm
    nodePackages."@angular/cli"
    # Clojure
    clojure babashka
    # Python
    python310Full
    # LaTeX
    (texlive.combine {
      inherit (texlive) scheme-full kpfonts fontspec titlesec enumitem changepage;
    })
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
    extraConfig = builtins.readFile ./vimrc;
  };
}
