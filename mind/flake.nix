{
  description = "Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs }:
  let
    name = "james";
    system = "MIND";
    options = import ./options.nix { defaultUsername = name; };
    systemConfiguration = import ./system.nix { flake = self; };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#MIND
    darwinConfigurations."${system}" = nix-darwin.lib.darwinSystem {
      modules = [
        options
        systemConfiguration

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