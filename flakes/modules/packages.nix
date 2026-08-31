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
        nodejs_22 # Node.js 22 LTS — bundles `npm` (matches the portal's shell.nix)

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
