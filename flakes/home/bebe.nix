{ config, pkgs, ... }:

{
  home.username = "bebe";
  home.homeDirectory = "/home/bebe";

  home.stateVersion = "25.11";

  programs.git = {
    enable = true;
    userName  = "Bengula Jacob";
    userEmail = "kbengula@student.maseno.ac.ke";

    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.gnome-shell.enable = true;
  programs.fish.enable = true;
  programs.starship.enable = true;
  programs.neovim.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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

