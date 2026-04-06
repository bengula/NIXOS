{ config, pkgs, ... }:

{
  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-tour
    gnome-music
    geary
  ];

  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.rtkit.enable = true;

  #services.displayManager.autoLogin.enable = true;
  #services.displayManager.autoLogin.user = "bengula";

  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@tty1".enable = false;
}

