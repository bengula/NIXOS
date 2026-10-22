# Super + Shift + Tab — jump to any open window by name.
#
# Super + Tab cycles workspaces, which is the right tool when you know where
# a window is. This is for when you don't: every mapped window on every
# workspace in one searchable list.
#
# Same TSV trick as ./hyprland-keys.nix and ./waybar.nix's wifi picker — the
# padded line is what wofi shows, the window address travels in a hidden
# column. Matching a window by its title instead would pick the wrong one of
# two Chrome windows, and lose to any title containing a tab character.
{
  flake.modules.homeManager.window-switcher =
    { pkgs, ... }:
    let
      hypr-windows = pkgs.writeShellScriptBin "hypr-windows" ''
        set -eu

        tmp=$(${pkgs.coreutils}/bin/mktemp)
        trap '${pkgs.coreutils}/bin/rm -f "$tmp"' EXIT

        # `mapped` filters out windows that exist but have no surface yet.
        # Special workspaces have negative ids; the scratchpad (Super + S) is
        # one of those and its window is worth reaching from here too, so they
        # are kept — only the id's sign is used, for the label.
        ${pkgs.hyprland}/bin/hyprctl clients -j |
          ${pkgs.jq}/bin/jq -r '
            .[]
            | select(.mapped)
            | [ (if .workspace.id < 0 then "scratch" else "ws \(.workspace.name)" end)
              , .class
              , (.title | gsub("[\\t\\n]"; " "))
              , .address
              ] | @tsv' |
          ${pkgs.gawk}/bin/awk -F'\t' '
            { printf "%-10s  %-22s  %s\t%s\n", $1, substr($2, 1, 22), $3, $4 }' > "$tmp"

        if [ ! -s "$tmp" ]; then
          ${pkgs.libnotify}/bin/notify-send -u low -r 9004 \
            "Windows" "Nothing open"
          exit 0
        fi

        sel=$(${pkgs.coreutils}/bin/cut -f1 "$tmp" |
              ${pkgs.wofi}/bin/wofi --dmenu --insensitive \
                --prompt "Go to window" --width 820 --height 480 \
                --cache-file /dev/null) || exit 0
        [ -n "$sel" ] || exit 0

        addr=$(${pkgs.gawk}/bin/awk -F'\t' -v s="$sel" '$1 == s { print $2; exit }' "$tmp")
        [ -n "$addr" ] || exit 0

        # Lua config: the dispatcher is an hl.dsp.* call, not a bare word.
        ${pkgs.hyprland}/bin/hyprctl dispatch \
          "hl.dsp.focus({ window = \"address:$addr\" })"
      '';
    in
    {
      home.packages = [ hypr-windows ];
    };
}
