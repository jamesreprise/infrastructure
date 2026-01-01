{ config, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./wireguard.nix
      <agenix/modules/age.nix>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "outpost-1"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Configure Nix
  nix.nixPath = [
    "nixpkgs=https://nixos.org/channels/nixpkgs-unstable"
    "nixos-config=/etc/nixos/configuration.nix"
    "agenix=https://github.com/ryantm/agenix/archive/main.tar.gz"
  ];

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.james = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBAe6xY4upI5IiWbLG6AJ17dJ4AqcDJ60mB+AauJjoEJ"];
    packages = with pkgs; [
      tree
    ];
  };
  users.users.root = {
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBAe6xY4upI5IiWbLG6AJ17dJ4AqcDJ60mB+AauJjoEJ"];
  };

  environment.systemPackages = with pkgs; [
    vim
    curl
    (callPackage <agenix/pkgs/agenix.nix> {})
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "without-password";
      PasswordAuthentication = false;
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # Do NOT change this value.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
