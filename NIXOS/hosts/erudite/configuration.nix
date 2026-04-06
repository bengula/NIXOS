{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
  ];

  networking.hostName = "Erudite";

  # REQUIRED – never change after first install
  system.stateVersion = "26.05";
}

