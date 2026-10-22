{ config, ... }:

let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.homeManager.bebe =
    { pkgs, ... }:
    {
      imports = [
        homeManager.base
        homeManager.dev
        homeManager.terminal
        homeManager.hyprland
        homeManager.hyprland-keys
        homeManager.wofi
        homeManager.waybar
        homeManager.dynamic-island
        homeManager.lock
        homeManager.wallpaper
        homeManager.window-rules
        homeManager.window-switcher
        homeManager.clipboard
        homeManager.record
        homeManager.picker
        homeManager.emoji
        homeManager.zoom
        homeManager.nightlight
        homeManager.theme
        homeManager.default-apps
        homeManager.automount
        homeManager.polkit
      ];

      home.username = "bebe";
      home.homeDirectory = "/home/bebe";

      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "Bengula Jacob";
            email = "kbengula@student.maseno.ac.ke";
          };
          init.defaultBranch = "main";
          pull.rebase = true;
        };
      };

      home.packages = with pkgs; [
        gnome-extension-manager
        homebank
      ];
    };
}
