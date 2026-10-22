# Screen recording, with the bar as the stop button.
#
# The one thing a screen recorder must never do is leave you unsure whether it
# is running. So there is a single toggle per mode (press to start, press
# again to stop), a red pill in the bar with a running clock while it records
# — the `custom/rec` module, which is invisible otherwise — and a notification
# naming the file when it stops.
#
# wf-recorder has to be stopped with SIGINT rather than killed: the muxer
# writes the MP4 index on the way out, and a recording killed with SIGTERM is
# an unplayable file.
{
  flake.modules.homeManager.record =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      hypr-rec = pkgs.writeShellScriptBin "hypr-rec" ''
        set -eu

        state="''${XDG_RUNTIME_DIR:-/tmp}/hypr-rec"
        ${pkgs.coreutils}/bin/mkdir -p "$state"
        pathfile="$state/current"
        startfile="$state/started"

        notify() { ${pkgs.libnotify}/bin/notify-send -r 9005 "$@"; }
        running() { ${pkgs.procps}/bin/pidof wf-recorder >/dev/null 2>&1; }

        # waybar re-runs the module on SIGRTMIN+8, so the pill appears and
        # disappears on the same keypress instead of up to a second later.
        refresh() { ${pkgs.procps}/bin/pkill -RTMIN+8 waybar >/dev/null 2>&1 || true; }

        stop() {
          running || return 0
          ${pkgs.procps}/bin/pkill -INT -x wf-recorder || true

          # Wait for the muxer to write the index — the file is not playable
          # until wf-recorder is actually gone. 5s is far longer than it takes.
          i=0
          while running && [ "$i" -lt 50 ]; do
            ${pkgs.coreutils}/bin/sleep 0.1
            i=$((i + 1))
          done

          file=$(${pkgs.coreutils}/bin/cat "$pathfile" 2>/dev/null || true)
          ${pkgs.coreutils}/bin/rm -f "$pathfile" "$startfile"
          refresh

          if [ -n "$file" ] && [ -s "$file" ]; then
            notify "Recording saved" "$file"
          else
            notify -u critical "Recording failed" "Nothing was written"
          fi
        }

        start() {
          mode=$1
          audio=$2

          dir="''${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings"
          ${pkgs.coreutils}/bin/mkdir -p "$dir"
          # No ":" in the name — recordings get copied to FAT sticks, same
          # reason as the screenshots in ./hyprland-keys.nix.
          file="$dir/$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S).mp4"

          set -- -f "$file"

          if [ "$mode" = region ]; then
            # Cancelling slurp must not fall through to recording the whole
            # screen by accident.
            geom=$(${pkgs.slurp}/bin/slurp) || exit 0
            set -- "$@" -g "$geom"
          else
            # Name the output explicitly: with no -o, wf-recorder takes the
            # first one it finds, which is the wrong screen as soon as a second
            # monitor is plugged in.
            out=$(${pkgs.hyprland}/bin/hyprctl monitors -j |
                  ${pkgs.jq}/bin/jq -r 'map(select(.focused)) | .[0].name // empty')
            if [ -n "$out" ]; then
              set -- "$@" -o "$out"
            fi
          fi

          if [ "$audio" = yes ]; then
            set -- "$@" --audio
          fi

          printf '%s\n' "$file" > "$pathfile"
          ${pkgs.coreutils}/bin/date +%s > "$startfile"

          # setsid so the recorder outlives this script: Hyprland reaps the
          # keybind's shell as soon as the script returns.
          ${pkgs.util-linux}/bin/setsid -f ${pkgs.wf-recorder}/bin/wf-recorder "$@" \
            >"$state/log" 2>&1

          ${pkgs.coreutils}/bin/sleep 0.4

          if running; then
            refresh
            if [ "$audio" = yes ]; then
              notify -u low "Recording (with audio)" "Press the same keys again to stop"
            else
              notify -u low "Recording" "Press the same keys again to stop"
            fi
          else
            ${pkgs.coreutils}/bin/rm -f "$pathfile" "$startfile"
            notify -u critical "Recording failed" \
              "$(${pkgs.coreutils}/bin/tail -3 "$state/log" 2>/dev/null || true)"
          fi
        }

        # Every mode is a toggle, so the key that started a recording always
        # stops it — whichever mode it was started in.
        case "''${1:-region}" in
          region) if running; then stop; else start region no; fi ;;
          screen) if running; then stop; else start screen no; fi ;;
          audio)  if running; then stop; else start screen yes; fi ;;
          stop)   stop ;;
          status)
            if running; then
              started=$(${pkgs.coreutils}/bin/cat "$startfile" 2>/dev/null || echo 0)
              now=$(${pkgs.coreutils}/bin/date +%s)
              if [ "$started" -gt 0 ]; then elapsed=$((now - started)); else elapsed=0; fi
              printf '{"text":"  %02d:%02d","tooltip":"Recording — click to stop","class":"recording"}\n' \
                "$((elapsed / 60))" "$((elapsed % 60))"
            else
              # Valid JSON with empty text rather than an empty line: waybar
              # hides a custom module whose text is empty — padding, margin
              # and all — but logs a parse error on output that is not JSON.
              printf '{"text":""}\n'
            fi
            ;;
          *)
            printf 'usage: hypr-rec [region|screen|audio|stop|status]\n' >&2
            exit 1
            ;;
        esac
      '';
    in
    {
      home.packages = [ hypr-rec ];

      # The module is defined here; its position in the bar is the one line
      # added to `modules-right` in ./waybar.nix.
      programs.waybar.settings.mainBar."custom/rec" = {
        exec = "${hypr-rec}/bin/hypr-rec status";
        return-type = "json";
        interval = 1;
        signal = 8;
        on-click = "${hypr-rec}/bin/hypr-rec stop";
      };

      programs.waybar.style = lib.mkAfter ''
        /* Invisible whenever hypr-rec prints nothing — waybar hides a custom
           module with empty text, padding and margin included. */
        #custom-rec {
          color: ${config.look.palette.bg};
          background: ${config.look.palette.alarm};
          padding: 0 12px;
          margin: 4px 4px;
          border-radius: ${toString (config.look.rounding - 2)}px;
          font-weight: bold;
        }
      '';
    };
}
