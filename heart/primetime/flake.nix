{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }: {
    nixosConfigurations.primetime = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
  };
}
