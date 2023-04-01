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
    gnupg pinentry-curses
    temurin_x86_64
    bazelisk 
  ] ++ scripts;

  home.sessionVariables = {
    JAVA_HOME = "${temurin_x86_64}";
  };

  home.file.".gnupg/gpg-agent.conf".text = "pinentry-agent ${pkgs.pinentry-curses}";

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
