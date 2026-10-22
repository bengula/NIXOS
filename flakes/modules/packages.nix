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

        # Productivity
        libreoffice
        obsidian
        thunderbird
        codex
        claude-code

        # Development
        vscodium
        python3
        texliveFull
        nodejs # Node.js Active LTS (or `nodejs_22` / `nodejs_24`)

        # Browsers
        google-chrome
        antigravity-ide

        # Media
        vlc # every user gets it; the island's mpris module already knows it
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
        gnomeExtensions.gsconnect
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
