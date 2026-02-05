{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users = {
      bebe    = import ../home/bebe.nix;
      lovelty = import ../home/lovelty.nix;
    };
  };
}

