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
    dunst
    wl-clipboard
    grim
    slurp
    brightnessctl
    pamixer
  ];
}
