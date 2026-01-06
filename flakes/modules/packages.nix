{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    fish
    libreoffice
    vscodium
    python3
    texliveFull
    obsidian
    ungoogled-chromium
    nix-output-monitor
  ];

  programs.firefox.enable = true;
  programs.fish.enable = true;

  services.printing.enable = true;
  services.openssh.enable = true;
}

