{ config, pkgs, ... }:

{
  home.username = "lovelty";
  home.homeDirectory = "/home/lovelty";
  home.stateVersion = "25.11";
 # This enables the 'home-manager' command in your shell
  programs.home-manager.enable = true; 
  
  programs.git.enable = true;

  home.packages = with pkgs; [
    thunderbird
    
  ];
}

