{ config, pkgs, ... }:

{
  home.username = "bebe";
  home.homeDirectory = "/home/bebe";

  home.stateVersion = "25.11";

  programs.git.enable = true;

  programs.gnome-shell.enable = true;
  
  programs.fish.enable = true;

  programs.starship.enable = true;

  programs.neovim.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  
  programs.git = {
  	enable = true; 
  	settings = {
  		user = { 
  			name = "Bengula Jacob"; 
  			email = "kbengula@student.maseno.ac.ke";
  			};
  		   };
  	        };

  home.packages = with pkgs; [
    gnome-tweaks
    obsidian
    homebank
    gnome-extension-manager
    fd
    ripgrep
    eza
  ];
}

