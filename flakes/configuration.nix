{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./modules/nix.nix
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/locale.nix
    ./modules/desktop-gnome.nix
    ./modules/users.nix
    ./modules/packages.nix
    ./modules/home-manager.nix
  ];
}

