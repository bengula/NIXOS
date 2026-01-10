{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules
  ];

  networking.hostName = "Erudite";

  # REQUIRED – never change after first install
  system.stateVersion = "26.05";
}

