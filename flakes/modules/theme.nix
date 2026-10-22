# This user's look, as far as the toolkits can be told about it.
#
# Kitty, waybar, wofi and hyprlock all paint themselves from `config.look`,
# but nothing told the *toolkits*: GTK apps (Nautilus, the file chooser every
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
#
# Toolkit apps cannot be told a palette — GTK takes a theme, not a set of
# colours — so what reaches them from ../looks/ is the three choices that do
# survive that interface: the UI font, the cursor, and libadwaita's named
# accent colour. Everything else here is the same for every user.
{
  flake.modules.homeManager.theme =
    {
      pkgs,
      lib,
      config,
      ...
    }:
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
          inherit (config.look.font) name size package;
        };
      };

      # libadwaita's accent colour, one of its nine named values (GNOME 47+),
      # and the only way to stop GTK4 apps being Adwaita blue inside a session
      # that is not. Looks that do not ask for one leave the key unset rather
      # than writing a default, so GNOME keeps whatever it had; older
      # libadwaita ignores the key rather than failing. Written through dconf,
      # so it is shared with the GNOME session for the same reason the dark
      # scheme is.
      dconf.settings."org/gnome/desktop/interface" = lib.mkIf (config.look.accent != null) {
        accent-color = config.look.accent;
      };

      # Cursor theme and size in one place: this writes the GTK setting, the
      # X11/XWayland cursor, ~/.icons/default for Wayland clients, and the
      # session's XCURSOR_* variables. Setting `gtk.cursorTheme` directly
      # instead would leave XWayland apps on the default black Adwaita cursor.
      # The size comes from the look, and ./desktop-hyprland.nix exports
      # XCURSOR_SIZE from the same place, so the two cannot drift.
      home.pointerCursor = {
        enable = true;
        inherit (config.look.cursor) name package size;
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
