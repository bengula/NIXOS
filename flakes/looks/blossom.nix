# Blossom — `lovelty`'s look: a deep plum ground under pink and lilac.
#
# Same shape as ./tokyonight.nix, value for value: every attribute the
# consumers read is defined here, because ../modules/look.nix's default is
# replaced wholesale rather than merged when a user picks a look.
{ pkgs }:
{
  palette = {
    # ── Surfaces ──────────────────────────────────────────────────────────
    bg = "#1e1420"; # windows, the bar, the launcher
    bgDeep = "#170f1b"; # terminal ANSI black
    bgFloat = "#160d18"; # the island pill and tooltips, which float over windows
    surface = "#2b1f33"; # the wallpaper's mid tone
    overlay = "#4e3654"; # inactive borders, input grounds, ANSI bright black
    shadow = "#120a16"; # window drop shadow

    # ── Text ──────────────────────────────────────────────────────────────
    fg = "#f6dcec";
    fgSoft = "#e0bdd4"; # window titles, the lock screen's date
    hint = "#c2a0b8"; # placeholder text
    muted = "#9b7399"; # inactive workspaces, a paused player, "off"

    # ── Accents ───────────────────────────────────────────────────────────
    primary = "#ff8ec7"; # focus, active workspace, selection
    secondary = "#cba6ff"; # the keys button, play/pause
    attention = "#ffc48c"; # a mode is on, battery warning, password checking
    alarm = "#ff6b9d"; # critical notifications, recording, failure
    success = "#a7e8c0"; # ANSI green
    info = "#a8d8ff"; # ANSI cyan, the weather glyph
  };

  # Softer corners than Tokyo Night's 10 — the pink surfaces read as cards
  # rather than panels, and square corners fought that.
  rounding = 14;

  # Geometric and round rather than humanist, which is the single biggest
  # difference in how the toolkit apps read. nixpkgs ships the variable build,
  # Quicksand[wght].ttf: one file with a wght axis of 300-700, which
  # fontconfig exposes both as that range and as four named instances (Light,
  # Regular, Medium, Bold). So a bold label is a real cut rather than a
  # synthesised smear, and nothing here has to pick a weight by hand.
  font = {
    name = "Quicksand";
    package = pkgs.quicksand;
    size = 11;
  };

  # Ice is the white Bibata: a light cursor is the easier one to find on a
  # ground this dark.
  cursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  # Stops GTK4 apps from staying Adwaita blue inside a pink session.
  accent = "pink";

  lockGlyph = "󰋑  ";

  # Above Orbit's 0.72 default so the wave takes the palette's pinks instead
  # of only being tinted by them.
  wallpaperStrength = "0.88";
}
