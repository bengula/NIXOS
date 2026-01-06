{ config, pkgs, ... }:

{
  home.username = "bengula";
  home.homeDirectory = "/home/bengula";

  home.stateVersion = "25.11";



  home.packages = with pkgs; [
    thunderbird

  ];
}

