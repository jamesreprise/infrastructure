{ pkgs, osConfig, ... }:

let
  name = osConfig.username;
in
{
  # Don't change.
  home.stateVersion = "23.11";

  home.username = name;
  home.homeDirectory = "/Users/${name}";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true; 

  programs.fish.enable = true;
}