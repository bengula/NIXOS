# Super + . — the emoji picker, in the same wofi the rest of the session uses.
#
# bemoji rather than a hand-rolled list: it ships the emoji data, keeps a
# most-recently-used cache so the ones you actually use float to the top, and
# takes its picker from $BEMOJI_PICKER_CMD — which is how it ends up styled
# like everything else here instead of opening a second, differently-themed
# launcher.
{
  flake.modules.homeManager.emoji =
    { pkgs, ... }:
    let
      hypr-emoji = pkgs.writeShellScriptBin "hypr-emoji" ''
        set -eu

        # -c copies to the clipboard, -n includes the name in the list so the
        # thing is searchable in words ("shrug", "fire") rather than by
        # recognising a glyph in a grid.
        BEMOJI_PICKER_CMD="${pkgs.wofi}/bin/wofi --dmenu --insensitive --prompt Emoji --width 480 --height 480 --cache-file /dev/null" \
        ${pkgs.bemoji}/bin/bemoji -n -c

        # Nothing is typed into the focused window: paste is one keystroke and
        # synthesising input lands in the wrong place as often as not. The
        # clipboard also keeps it for the next three times you need it.
      '';
    in
    {
      home.packages = [
        hypr-emoji
        pkgs.bemoji
        pkgs.wl-clipboard
      ];
    };
}
