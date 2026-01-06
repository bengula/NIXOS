{
  description = "Erudite NixOS system (flakes + HM)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.Erudite = nixpkgs.lib.nixosSystem {
        inherit system;

        # REQUIRED: pass inputs to modules
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./configuration.nix

          # Home Manager NixOS module
          home-manager.nixosModules.home-manager

          # Base HM settings
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
    };
}

