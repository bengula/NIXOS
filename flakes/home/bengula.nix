{ config, pkgs, ... }:

{
  home.username = "bengula";
  home.homeDirectory = "/home/bengula";
  home.stateVersion = "25.11";

  programs.git.enable = true;

  home.packages = with pkgs; [
    thunderbird
  ];
}

