{ config, pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  # Enable Blueman service for D-Bus integration and Polkit permission management (crucial for non-root users in 'bluetooth' group)
  services.blueman.enable = true;
}
