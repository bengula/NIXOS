{
  description = "Erudite NixOS system (flakes + unstable)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Optional but recommended
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        Erudite = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./configuration.nix
          ];

          # Allow unfree packages globally
          specialArgs = {
            inherit system;
          };
        };
      };
    };
}

