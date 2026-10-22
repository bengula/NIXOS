# Super + scroll — magnify the screen around the cursor.
#
# Useful twice: reading something set in 8px, and presenting, where the
# alternative is apologising for the font size.
#
# Hyprland's zoom is the `cursor:zoom_factor` *config value*, not a
# dispatcher, so this goes through `hyprctl eval` — under a Lua config
# `hyprctl keyword` does not exist, and `hyprctl dispatch` would try to
# evaluate it as a dispatcher. Reading the current value back out with
# `hyprctl getoption` is what makes the steps relative rather than a set of
# fixed levels.
{
  flake.modules.homeManager.zoom =
    { pkgs, ... }:
    let
      hypr-zoom = pkgs.writeShellScriptBin "hypr-zoom" ''
        set -eu

        hyprctl=${pkgs.hyprland}/bin/hyprctl

        current=$($hyprctl getoption cursor:zoom_factor -j |
                  ${pkgs.jq}/bin/jq -r '.float // 1')

        # Multiplicative steps: a fixed +0.25 is a huge jump at 1.0 and barely
        # perceptible at 4.0. 1 is "no zoom" and the hard floor — Hyprland
        # refuses anything below it — and 6 is well past useful.
        target=$(${pkgs.gawk}/bin/awk -v c="$current" -v op="''${1:-reset}" '
          BEGIN {
            if (op == "in")       t = c * 1.25
            else if (op == "out") t = c / 1.25
            else                  t = 1
            if (t < 1.02) t = 1
            if (t > 6)    t = 6
            printf "%.4f", t
          }')

        $hyprctl eval "hl.config({ cursor = { zoom_factor = $target } })" >/dev/null

        # One replaceable notification rather than a stack of them, and none
        # at all once the zoom is back to normal — the screen itself is the
        # feedback at that point.
        if ${pkgs.gawk}/bin/awk -v t="$target" 'BEGIN { exit !(t > 1.02) }'; then
          ${pkgs.libnotify}/bin/notify-send -r 9008 -t 1200 -u low \
            "Zoom" "$(${pkgs.gawk}/bin/awk -v t="$target" 'BEGIN { printf "%d%%", t * 100 }')"
        else
          ${pkgs.libnotify}/bin/notify-send -r 9008 -t 800 -u low "Zoom" "Off"
        fi
      '';
    in
    {
      home.packages = [ hypr-zoom ];
    };
}
