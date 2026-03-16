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
    android-tools   # This now handles the ADB logic
    v4l-utils       # Camera testing utilities
    droidcam        # The desktop client UI
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  programs.firefox.enable = true;
  programs.fish.enable = true;

  # DroidCam Drivers
  # This enables the v4l2loopback kernel module automatically
  programs.droidcam.enable = true;

  # Services
  services.printing.enable = true;
  services.openssh.enable = true;

  # Android USB permissions
  # In NixOS 26.05, we don't need 'programs.adb'. 
  # We just need the udev rules so the phone is recognized.
  services.udev.packages = [ 
    pkgs.android-udev-rules 
  ];
}
