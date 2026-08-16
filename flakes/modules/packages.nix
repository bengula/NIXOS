{
  flake.modules.nixos.packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Core utilities
        wget
        git
        gnome-tweaks
        libnotify # notify-send — used by the Hyprland mode hints

<<<<<<< HEAD
        # Productivity
        libreoffice
        obsidian
||||||| parent of 0ca3ed6 (added thunderbird)
    # Productivity
    libreoffice
    obsidian

    # Productivity
    libreoffice
    obsidian
    thunderbird
    codex

        # Development
        vscodium
        python3
        texliveFull
        nodejs_20 # Node.js 20 LTS — bundles `npm` (matches the portal's shell.nix)

        # Browsers
        google-chrome

        # Media
        spotify
        teams-for-linux
        telegram-desktop
        signal-desktop
        discord

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
    };
}
