{
  description = "Home Manager configuration of james";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixvim, ... } @ inputs:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      nixvim-hm-module = nixvim.homeModules.nixvim;
      nixvim-config = import ./nixvim.nix;
      home-config = import ./home.nix { nixvim = nixvim-config; };
    in {
      homeConfigurations."james" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [ home-config nixvim-hm-module ];
      };
    };
}
