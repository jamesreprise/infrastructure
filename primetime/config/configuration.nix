{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      # hardware-configuration.nix is omitted as it is hardware-specific.
      ./hardware-configuration.nix ./zfs.nix ./content.nix ./networking.nix
       <agenix/modules/age.nix>
    ];

  # Services
  services.openssh.permitRootLogin = "prohibit-password";

  # Users
  users.mutableUsers = false;
  users.users.james = {
    isNormalUser = true;
    home = "/home/james";
    group = "james";
    hashedPassword = "...";
    extraGroups = ["wheel"];
  };
  users.groups.james = {};
  services.openssh.enable = true;


  # Nix 
  nix.nixPath = [
    "nixpkgs=https://nixos.org/channels/nixpkgs-unstable"
    "nixos-config=/etc/nixos/configuration.nix"
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.11"; 
  

  # System packages 
  environment.systemPackages = with pkgs; [ 
    ncdu htop tmux git (callPackage <agenix/pkgs/agenix.nix> {}) 
  ];
}