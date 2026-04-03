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

  # Audio (PipeWire replaces PulseAudio)
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  #PAM is still important
  security.pam.services.login.enable = true;
  security.pam.services.gdm.enable = true;

  security.rtkit.enable = true;
}
