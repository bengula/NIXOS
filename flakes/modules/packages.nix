{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    git
    libreoffice
    vscodium
    python3
    texliveFull
    ungoogled-chromium
    nix-output-monitor
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  programs.firefox.enable = true;
  programs.fish.enable = true;

  services.printing.enable = true;
  services.openssh.enable = true;
}


