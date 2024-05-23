{ flake }:
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

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ pkgs.vim ];
  environment.shells = [ pkgs.fish ];
  programs.fish.enable = true;
  programs.zsh.enable = true;

  # Otherwise our home points to /var/empty (https://github.com/LnL7/nix-darwin/issues/423)
  users.users.${name}.home = "/Users/${name}";

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
}