{ flake, system }:
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
  # nix.package = pkgs.nix;

  nix.settings = {
    # Necessary for using flakes on this system.
    experimental-features = "nix-command flakes";
    substituters = ["https://devenv.cachix.org"];
    trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="];
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [ bazelisk ];
  environment.shells = [ pkgs.fish ];
  environment.pathsToLink = [ "/share/fish" ];
  programs.fish.enable = true;
  programs.zsh.enable = true;

  networking.hostName = system;

  # Otherwise our home points to /var/empty (https://github.com/LnL7/nix-darwin/issues/423)
  users.users.${name}.home = "/Users/${name}";

  system = {
    activationScripts.extraActivation.text = ''
      ln -sf "${pkgs.zulu}/zulu-21.jdk" "/Library/Java/JavaVirtualMachines/"
    '';
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
    ];
  };
}
