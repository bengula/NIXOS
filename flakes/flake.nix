{
  description = "Erudite NixOS system (flakes + Home Manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Source for the Bengula Inc portal (built reproducibly via buildNpmPackage
    # in modules/bengula-portal.nix). `flake = false` => plain source tree.
    bengula-portal-src = {
      url = "github:bengula/BengulaLive";
      flake = false;
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
        ./hosts/erudite
      ];
    };
  };
}
