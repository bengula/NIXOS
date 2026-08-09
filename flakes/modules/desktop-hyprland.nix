{ config, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    waybar
    wofi
    hyprpaper
    hyprlock
    dunst
    wl-clipboard
    grim
    slurp
    brightnessctl
    pamixer
  ];
}
