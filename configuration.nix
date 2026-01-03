{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  ############################
  # Nix / Flakes
  ############################
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  ############################
  # Bootloader
  ############################
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  ############################
  # Networking
  ############################
  networking.hostName = "Erudite";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];

  ############################
  # Time & Locale
  ############################
  time.timeZone = "Africa/Nairobi";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  ############################
  # Display / GNOME
  ############################
  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Remove unwanted GNOME apps (corrected paths)
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-tour
    gnome-music
  ];

  ############################
  # Sound (PipeWire – modern)
  ############################
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ############################
  # Users
  ############################
  users.users.bengula = {
    isNormalUser = true;
    description = "Bengula Jacob";
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [
      thunderbird
    ];
  };

  users.users.bebe = {
    isNormalUser = true;
    description = "Happy Home";
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [
      tree
      obsidian
      chromium
      homebank
      gnome-extension-manager
    ];
  };

  ############################
  # Auto-login (GNOME safe)
  ############################
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "bengula";

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  ############################
  # Printing
  ############################
  services.printing.enable = true;

  ############################
  # Programs
  ############################
  programs.firefox.enable = true;
  programs.fish.enable = true;

  ############################
  # System Packages
  ############################
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    libreoffice
    vscodium
    python3
    julia
    texliveFull
    obsidian
    nix-output-monitor
  ];

  ############################
  # Garbage Collection
  ############################
  nix.gc = {
    automatic = true;
    dates = "03:15";
    options = "--delete-older-than 7d";
  };

  ############################
  # Safety
  ############################
  ###system.copySystemConfiguration = true;

  ############################
  # DO NOT CHANGE
  ############################
  system.stateVersion = "25.11";
}

