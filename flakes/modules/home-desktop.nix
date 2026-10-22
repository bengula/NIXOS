# The whole Hyprland session, as one importable aspect.
#
# This used to be a 19-line import list inside ./home-bebe.nix. It lives here
# now because more than one user logs into Hyprland, and a second copy of that
# list in ./home-lovelty.nix would be two things to keep in step — the failure mode
# being a session that silently lacks a bar, a lock screen or a clipboard for
# one user only. Add a desktop aspect here and every Hyprland user gets it.
#
# Per-user choices (git identity, extra packages, shell) stay in the per-user
# files; nothing in this list is user-specific.
{ config, ... }:

let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.homeManager.desktop = {
    imports = [
      # Compositor and how it is driven
      homeManager.hyprland
      homeManager.hyprland-keys
      homeManager.window-rules
      homeManager.window-switcher

      # Shell surfaces
      homeManager.waybar
      homeManager.wofi
      homeManager.dynamic-island
      homeManager.lock
      homeManager.wallpaper

      # Tools bound from the keybinding list
      homeManager.clipboard
      homeManager.record
      homeManager.picker
      homeManager.emoji
      homeManager.zoom
      homeManager.nightlight

      # Session integration
      homeManager.theme
      homeManager.default-apps
      homeManager.automount
      homeManager.polkit
    ];
  };
}
