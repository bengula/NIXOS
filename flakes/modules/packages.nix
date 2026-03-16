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

    # Networking / tools
    packet
    nix-output-monitor

    # Android / camera tools
    android-tools   # adb command
    v4l-utils       # camera testing utilities
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  programs.firefox.enable = true;
  programs.fish.enable = true;

  # DroidCam + ADB
  programs.droidcam.enable = true;

  # Services
  services.printing.enable = true;
  services.openssh.enable = true;

  # Android USB permissions
  services.udev.packages = [ pkgs.android-udev-rules ];
}


