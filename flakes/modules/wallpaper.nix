# Animated shader wallpaper (Orbit Wallpaper Engine).
#
# This replaces hyprpaper. The renderer draws a GLSL fragment shader on the
# background layer and listens on a control FIFO for three commands — `intro`,
# `exit` and `palette` — which is how the wallpaper animates out when the
# screen locks and sweeps back in when it unlocks. That sequencing lives in
# ./lock.nix, so it degrades to a plain hyprlock if this aspect is left out.
#
# `nix build ./flakes#orbit-wallpaper-engine` builds just the renderer, which
# is a much faster way to iterate on a build failure than a full rebuild.
{ inputs, ... }:

let
  mkOrbit =
    pkgs:
    pkgs.callPackage ../pkgs/orbit-wallpaper-engine.nix {
      src = inputs.orbit-wallpaper-src;
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.orbit-wallpaper-engine = mkOrbit pkgs;
    };

  flake.modules.homeManager.wallpaper =
    { pkgs, config, ... }:
    let
      orbit = mkOrbit pkgs;
      palette = config.look.palette;

      # `%C` and not `%h/.cache`: for a user manager systemd resolves %C through
      # $XDG_CACHE_HOME, which is what the client scripts below and in ./lock.nix
      # do too. `%h` would hardcode ~/.cache, and anyone who moved their cache
      # dir would get a renderer listening on one FIFO path and a lock script
      # writing to another — with no error, because a missing FIFO is a no-op.
      cacheDir = "%C/orbit-wallpaper-engine";

      # The upstream reference integration, with store paths. Never blocks:
      # a missing FIFO is a no-op and a write with no reader times out, because
      # a cosmetic wallpaper must never be able to wedge a lock or a logout.
      orbit-wallpaper = pkgs.writeShellScriptBin "orbit-wallpaper" ''
        set -eu
        control="''${XDG_CACHE_HOME:-$HOME/.cache}/orbit-wallpaper-engine/control"
        case "''${1:-}" in
          intro|exit|palette)
            [ -p "$control" ] || exit 0
            ${pkgs.coreutils}/bin/timeout 0.5s \
              sh -c 'printf "%s\n" "$1" > "$2"' sh "$1" "$control" >/dev/null 2>&1 || true
            ;;
          *)
            printf 'usage: %s {intro|exit|palette}\n' "$0" >&2
            exit 2
            ;;
        esac
      '';
    in
    {
      home.packages = [
        orbit
        orbit-wallpaper
      ];

      # The renderer resolves shaders from the XDG data dir and from its own
      # user shader directory; wave.frag is the shipped default, so put it in
      # both. Drop further .frag files into ~/.config/orbit-wallpaper-engine/
      # shaders/ — the KDE Shader Wallpaper catalogue is the usual source.
      xdg.dataFile."orbit-wallpaper-engine/wave.frag".source =
        "${orbit}/share/orbit-wallpaper-engine/wave.frag";
      xdg.configFile."orbit-wallpaper-engine/shaders/wave.frag".source =
        "${orbit}/share/orbit-wallpaper-engine/wave.frag";

      # Bound to hyprland-session.target rather than graphical-session.target
      # on purpose: this needs wlr-layer-shell, so it must not try to start
      # when the GNOME session is chosen at GDM.
      systemd.user.services.orbit-wallpaper-engine = {
        Unit = {
          Description = "Orbit Wallpaper Engine";
          PartOf = [ "hyprland-session.target" ];
          After = [ "hyprland-session.target" ];
        };

        Service = {
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cacheDir}";
          ExecStart = "${orbit}/bin/orbit-wallpaper-engine";
          ExecReload = "${orbit-wallpaper}/bin/orbit-wallpaper intro";

          Environment = [
            "ORBIT_WALLPAPER_CONTROL_FILE=${cacheDir}/control"
            # hyprlock takes its own screenshot, so the PNG snapshot the
            # renderer can write for it is dead weight here.
            "ORBIT_WALLPAPER_DISABLE_SNAPSHOTS=1"

            "ORBIT_WALLPAPER_SHADER=wave.frag"

            # Timings. The intro is deliberately long — it is the thing you
            # see on unlock; the exit is quick because it plays behind the
            # lock screen where nobody is watching.
            "ORBIT_WALLPAPER_INTRO_DURATION=4.5"
            "ORBIT_WALLPAPER_EXIT_DURATION=1.0"

            # The same colours as the terminal and the window borders — the
            # wave shader tints itself from these, so the wallpaper is where
            # the look is most visible. How hard it is pulled towards them is
            # the look's call too: Orbit's 0.72 default is tuned for Tokyo
            # Night's own hues.
            "ORBIT_WALLPAPER_PRIMARY=${palette.primary}"
            "ORBIT_WALLPAPER_SECONDARY=${palette.secondary}"
            "ORBIT_WALLPAPER_SURFACE=${palette.surface}"
            "ORBIT_WALLPAPER_ERROR=${palette.alarm}"
            "ORBIT_WALLPAPER_PALETTE_STRENGTH=${config.look.wallpaperStrength}"
          ];

          Restart = "on-failure";
          RestartSec = 2;
          TimeoutStopSec = 5;
          FinalKillSignal = "SIGKILL";
        };

        Install.WantedBy = [ "hyprland-session.target" ];
      };
    };
}
