{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users = {
      bengula = import ../../home/bengula.nix;
      lovelty = import ../../home/lovelty.nix;
    };
  };
}

