# Warmer screen after dark, on a schedule — and Super + Shift + N to force it
# either way.
#
# The schedule is fixed times rather than computed sunrise/sunset because this
# machine lives on the equator (Malindi, same place ./dynamic-island.nix pins
# its weather to): sunrise and sunset move by about twenty minutes across the
# whole year, so a table beats a solar calculator and a location permission.
#
# hyprsunset owns the display gamma for the whole output. GNOME's own Night
# Light does too, so this is bound to hyprland-session.target — both running
# would stack two colour shifts on the same screen.
{
  flake.modules.homeManager.nightlight =
    { pkgs, ... }:
    let
      # The daemon holds the state; the toggle just tells it what to do and
      # remembers which way it was last pushed, because hyprsunset has no
      # "what are you doing now" query.
      hypr-night = pkgs.writeShellScriptBin "hypr-night" ''
        set -eu

        flag="''${XDG_RUNTIME_DIR:-/tmp}/hypr-night.on"
        hyprctl=${pkgs.hyprland}/bin/hyprctl
        notify() { ${pkgs.libnotify}/bin/notify-send -r 9007 -u low "Night light" "$1"; }

        # `hyprctl hyprsunset` talks to the daemon's own socket, so a clear
        # message beats the raw "Couldn't connect to ..." when it is not up.
        send() {
          if ! $hyprctl hyprsunset "$@" >/dev/null 2>&1; then
            notify "hyprsunset is not running"
            exit 1
          fi
        }

        warm() {
          send temperature 4000
          ${pkgs.coreutils}/bin/touch "$flag"
          notify "On — 4000K"
        }

        cool() {
          send identity
          ${pkgs.coreutils}/bin/rm -f "$flag"
          notify "Off — back to the panel's own colour"
        }

        case "''${1:-toggle}" in
          on) warm ;;
          off) cool ;;
          *) if [ -e "$flag" ]; then cool; else warm; fi ;;
        esac
      '';
    in
    {
      home.packages = [ hypr-night ];

      services.hyprsunset = {
        enable = true;

        # Not graphical-session.target: see the note at the top of the file.
        systemdTarget = "hyprland-session.target";

        settings = {
          # Gamma is a percentage here. Leaving the ceiling at 100 means the
          # evening profiles below can only ever dim, never overdrive.
          max-gamma = 100;

          profile = [
            # Daylight: no shift at all. `identity` rather than 6500K because
            # it skips the colour transform entirely.
            {
              time = "6:30";
              identity = true;
            }
            # Sunset. 4500K is a shift you notice once and then stop noticing.
            {
              time = "18:30";
              temperature = 4500;
            }
            # Late evening, closer to lamplight, and slightly dimmer.
            {
              time = "21:30";
              temperature = 3600;
              gamma = 90;
            }
          ];
        };
      };
    };
}
