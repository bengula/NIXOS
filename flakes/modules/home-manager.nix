{ config, pkgs, ... }:

{
  home-manager.users = {
    bengula = import ../home/bengula.nix;
    bebe    = import ../home/bebe.nix;
  };
}

