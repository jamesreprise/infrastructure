{
  description = "Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, nix-homebrew, homebrew-core, homebrew-cask, home-manager }:
  let
    name = "james";
    fullName = "James Williams";
    email = "james@berserksystems.com";
    system = "MIND";
    options = import ./options.nix { 
      defaultUsername = name;
      defaultFullName = fullName;
      defaultEmail = email;
    };
    systemConfiguration = import ./system.nix { flake = self; };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#MIND
    darwinConfigurations."${system}" = nix-darwin.lib.darwinSystem {
      modules = [
        options

        systemConfiguration

        nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            
            user = name;
            
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };
            mutableTaps = false;
          };
        }

        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${name}" = import ./home.nix;
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."${system}".pkgs;
  };
}
