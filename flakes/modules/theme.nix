# One dark look across the toolkits.
#
# Kitty, waybar, wofi and hyprlock are all styled Tokyo Night already, but
# nothing told the *toolkits*: GTK apps (Nautilus, the file chooser every
# browser opens, gnome-tweaks) came up in light Adwaita, and Qt apps — VLC
# being the obvious one — followed nothing at all and drew their own grey.
#
# The three pieces that have to agree:
#
#   * `gtk.colorScheme = "dark"` is what libadwaita apps read. GTK4/libadwaita
#     ignores `gtk-theme` entirely, so without this Nautilus stays light no
#     matter which GTK3 theme is set.
#   * adw-gtk3 is the GTK3 half: it is Adwaita's current styling backported to
#     GTK3, so GTK3 and GTK4 windows actually match rather than being two
#     different greys.
#   * Qt is pointed at the GTK platform theme, so Qt apps inherit all of the
#     above — including the GTK file chooser instead of Qt's own.
#
# dconf is shared with GNOME, so GNOME logins go dark too. That is deliberate:
# one appearance for the machine, not one per session.
{
  flake.modules.homeManager.theme =
    { pkgs, ... }:
    {
      gtk = {
        enable = true;
        colorScheme = "dark";

        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };

        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };

        font = {
          name = "Cantarell";
          size = 11;
          package = pkgs.cantarell-fonts;
        };
      };

      # Cursor theme and size in one place: this writes the GTK setting, the
      # X11/XWayland cursor, ~/.icons/default for Wayland clients, and the
      # session's XCURSOR_* variables. Setting `gtk.cursorTheme` directly
      # instead would leave XWayland apps on the default black Adwaita cursor.
      # Size 24 matches the XCURSOR_SIZE already exported in
      # ./desktop-hyprland.nix.
      home.pointerCursor = {
        enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
        gtk.enable = true;
      };

      qt = {
        enable = true;

        # "gtk3" makes Qt use the GTK platform theme — same colours, same file
        # chooser. The alternative, "qtct", means a second theming tool to
        # configure and keep in sync by hand.
        platformTheme.name = "gtk3";

        # The widget *style* still has to be named separately, and adwaita-dark
        # is the one that matches adw-gtk3-dark. Without it Qt apps draw the
        # Fusion style's light controls on a dark window.
        style.name = "adwaita-dark";
      };
    };
}
