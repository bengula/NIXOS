{ config, pkgs, ... }:

{
  home.username = "pri";
  home.homeDirectory = "/home/pri";
  home.stateVersion = "25.11";
 # This enables the 'home-manager' command in your shell
  programs.home-manager.enable = true; 
  
  programs.git.enable = true;

  home.packages = with pkgs; [
    thunderbird
    
  ];
}

