{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core utilities
    wget
    git

    # Productivity
    libreoffice
    obsidian

    # Development
    vscodium
    python3
    texliveFull

    # Browsers
    google-chrome

    # Media
    spotify
    teams-for-linux

    # Networking / tools
    packet
    nix-output-monitor
    blueman

    # Android / camera tools
    android-tools
    v4l-utils
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  programs.firefox.enable = true;
  programs.fish.enable = true;

  # DroidCam support
  programs.droidcam.enable = true;

  # Services
  services.printing.enable = true;
  services.openssh.enable = true;
}
