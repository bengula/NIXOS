# Super + Shift + C — pick a colour from anywhere on screen.
#
# hyprpicker already copies to the clipboard with -a, so the script exists for
# one reason: to tell you it worked. Without a notification the only way to
# find out whether you hit the pixel you meant is to paste it somewhere.
{
  flake.modules.homeManager.picker =
    { pkgs, ... }:
    let
      hypr-pick = pkgs.writeShellScriptBin "hypr-pick" ''
        set -eu

        # -a copies, -f hex also prints it here. Pressing Escape exits
        # non-zero with nothing on stdout, which must not notify.
        hex=$(${pkgs.hyprpicker}/bin/hyprpicker -a -f hex) || exit 0
        [ -n "$hex" ] || exit 0

        # dunst renders markup (markup = "full" in ./desktop-hyprland.nix), so
        # the swatch is the colour itself rather than a description of it.
        ${pkgs.libnotify}/bin/notify-send -r 9006 -t 5000 \
          "Colour copied" "<span background='$hex'>      </span>  <tt>$hex</tt>"
      '';
    in
    {
      home.packages = [
        hypr-pick
        pkgs.hyprpicker
      ];
    };
}
