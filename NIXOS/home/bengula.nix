{ config, pkgs, ... }:

{
  home.username = "bengula";
  home.homeDirectory = "/home/bengula";
  home.stateVersion = "25.11";
  
 # This enables the 'home-manager' command in your shell
  programs.home-manager.enable = true; 
  
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "Bengula Jacob";
        email = "kbengula@student.maseno.ac.ke";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.fish.enable = true;

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.neovim.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    gnome-tweaks
    telegram-desktop
    signal-desktop
    discord
    gnome-extension-manager
    homebank
    fd
    ripgrep
    eza
  ];
}

