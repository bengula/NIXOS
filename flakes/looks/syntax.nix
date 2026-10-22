# The colour syntaxes the look files cannot express on their own.
#
# A look (./tokyonight.nix, ./blossom.nix) is nothing but data — `#rrggbb` per
# role — because three of its consumers want that colour spelled differently
# and none of them can be given a hex literal as-is:
#
#   * GTK CSS (waybar, wofi) takes `#rrggbb`, and gets translucency from GTK's
#     own `alpha(#rrggbb, 0.72)` rather than from a second literal — that is
#     what keeps the translucent surfaces tied to the look.
#   * Hyprland and hyprlock take `rgba(rrggbbaa)` with no `#`, and treat a
#     missing alpha as an error rather than as opaque → `hypr`.
#   * Pango markup (the island's weather glyph, the lock screen's placeholder)
#     wants a bare `rrggbb` → `bare`, written `#${bare x}` in waybar's JSON
#     and `##${bare x}` inside hyprlock's config, which strips one `#`.
#
# These are plain functions rather than part of the look because they are the
# same whichever look is in use.
{
  # "#ff8ec7" → "ff8ec7"
  bare = color: builtins.substring 1 6 color;

  # "#ff8ec7" "cc" → "rgba(ff8ec7cc)"
  hypr = color: alpha: "rgba(${builtins.substring 1 6 color}${alpha})";
}
