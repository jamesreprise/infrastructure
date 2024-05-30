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
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true; 

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -x GPG_TTY (tty)
    '';
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
    userName = "James Williams";
    userEmail = "james@berserksystems.com";

    signing = {
      signByDefault = true;
      key = null;
    };
  };
}
