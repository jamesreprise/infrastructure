{ config, lib, pkgs, ... }:
let
  name = <name>
in {
  imports = [
    ./terminal.nix
    ./development.nix
  ];

  home.username = name;
  home.homeDirectory = "/Users/${name}";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    bind ripgrep tig
    terraform magic-wormhole certbot
  ];
}
