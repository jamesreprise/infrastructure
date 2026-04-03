{ flake, systemName }:
{ pkgs, config, ... }:
let
  name = config.username;
in
{
  # Set Git commit hash for darwin-version.
  system.configurationRevision = flake.rev or flake.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  system.primaryUser = "james";

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    # Necessary for using flakes on this system.
    experimental-features = "nix-command flakes";
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.shells = [ pkgs.fish ];
  environment.pathsToLink = [ "/share/fish" ];
  programs.fish.enable = true;
  programs.zsh.enable = true;

  networking.hostName = systemName;

  # Otherwise our home points to /var/empty (https://github.com/LnL7/nix-darwin/issues/423)
  users.users.${name}.home = "/Users/${name}";

  system = {
    defaults = {
      ".GlobalPreferences" = {
        "com.apple.sound.beep.sound" = "/System/Library/Sounds/Frog.aiff";
      };
      NSGlobalDomain = {
        _HIHideMenuBar = true;
        "com.apple.sound.beep.volume" = 0.4723665;
      };
      menuExtraClock.IsAnalog = true;
      loginwindow = {
        SHOWFULLNAME = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  homebrew = {
    enable = true;
    casks = [
      "iterm2"
      "firefox"
      "spotify"
      "whatsapp"
      "element"
      "rectangle"
    ];
  };
}
