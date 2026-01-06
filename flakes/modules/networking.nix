{ config, pkgs, ... }:

{
  networking.hostName = "Erudite";
  networking.networkmanager.enable = true;

  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
  ];
}

