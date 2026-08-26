# XDG desktop portals — the thing that decides what happens when an app asks
# to open a file, share a screen or pick a colour.
#
# This is its own aspect because two sessions are installed and they need
# different answers. `programs.hyprland` already pulls in
# xdg-desktop-portal-hyprland (screencast, global shortcuts) and GNOME pulls in
# xdg-desktop-portal-gnome, but neither of them chooses a *file chooser* — with
# no `config` set, xdg-desktop-portal picks by an undefined order and warns
# about it at eval time. Naming the preference here is what makes "Upload" in
# Chrome open a real dialog under Hyprland.
{
  flake.modules.nixos.portals =
    { pkgs, lib, ... }:
    {
      xdg.portal = {
        enable = true;

        # GTK's portal is the fallback file chooser for both sessions.
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

        # Keys are matched against $XDG_CURRENT_DESKTOP. First implementation
        # in the list that provides the requested interface wins.
        config = {
          common.default = [ "gtk" ];
          gnome.default = lib.mkDefault [
            "gnome"
            "gtk"
          ];
          hyprland.default = [
            "hyprland"
            "gtk"
          ];
        };
      };
    };
}
