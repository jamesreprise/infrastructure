let 
  name = <name>
  arch = <arch>
in {
  description = "Home Manager config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ...}:
  {
    defaultPackage.${arch} =
      home-manager.defaultPackage.${arch};
    
    homeConfigurations.name =
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${arch};
        modules = [ ./home.nix ];
      };
    };
}
