# Tokyo Night — the default look, and the one `bebe` uses.
#
# A look is one user's whole appearance: the colours every surface is painted
# from, plus the handful of non-colour choices that have to agree with them.
# ../modules/look.nix declares the option, ../modules/home-lovelty.nix is an
# example of a user choosing a different one (./blossom.nix).
#
# Roles, not hues, are what the consumers reference — `primary` is "the focus
# colour", which here happens to be blue and in blossom happens to be pink —
# so a new look is this file with different values, never a new attribute.
{ pkgs }:
{
  palette = {
    # ── Surfaces ──────────────────────────────────────────────────────────
    bg = "#1a1b26"; # windows, the bar, the launcher
    bgDeep = "#15161e"; # terminal ANSI black
    bgFloat = "#101119"; # the island pill and tooltips, which float over windows
    surface = "#24283b"; # the wallpaper's mid tone
    overlay = "#414868"; # inactive borders, input grounds, ANSI bright black
    shadow = "#0d0e14"; # window drop shadow

    # ── Text ──────────────────────────────────────────────────────────────
    fg = "#c0caf5";
    fgSoft = "#a9b1d6"; # window titles, the lock screen's date
    hint = "#8a92b2"; # placeholder text
    muted = "#565f89"; # inactive workspaces, a paused player, "off"

    # ── Accents ───────────────────────────────────────────────────────────
    primary = "#7aa2f7"; # focus, active workspace, selection
    secondary = "#bb9af7"; # the keys button, play/pause
    attention = "#e0af68"; # a mode is on, battery warning, password checking
    alarm = "#f7768e"; # critical notifications, recording, failure
    success = "#9ece6a"; # ANSI green
    info = "#7dcfff"; # ANSI cyan, the weather glyph
  };

  # One number the surfaces derive their corners from, so they round together:
  # windows and dunst take it as-is, wofi's frame is +4 and its rows take it,
  # the bar's pills are -2.
  rounding = 10;

  # The toolkit UI font — GTK and, through the GTK platform theme, Qt.
  font = {
    name = "Cantarell";
    package = pkgs.cantarell-fonts;
    size = 11;
  };

  cursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  # libadwaita's named accent colour (GNOME 47+), or null to leave GTK4 apps
  # on Adwaita's own blue.
  accent = null;

  # Prefixed to the username on the lock screen.
  lockGlyph = "";

  # How hard the shader wallpaper is pulled towards the palette above.
  # 0.72 is Orbit's own default, which is tuned for exactly these colours.
  wallpaperStrength = "0.72";
}
