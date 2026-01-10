{
  description = "Erudite NixOS system (flakes + HM)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.Erudite = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };

      modules = [
        ./configuration.nix
        ./modules/home-manager.nix
      ];
    };
  };
}

