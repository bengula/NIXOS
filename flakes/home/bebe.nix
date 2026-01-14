{ config, pkgs, ... }:

{
  home.username = "bebe";
  home.homeDirectory = "/home/bebe";
  home.stateVersion = "25.11";

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
    whatsapp-for-mac
    gnome-extension-manager
    homebank
    fd
    ripgrep
    eza
  ];
}

