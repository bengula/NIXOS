{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users = {
      lovelty    = import ../home/bebe.nix;
      bengula = import ../home/lovelty.nix;
    };
  };
}

