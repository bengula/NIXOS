# Clipboard history (Super + Shift + V) and a clipboard that outlives the app
# you copied from.
#
# Two separate problems, which is why there are two services:
#
#   * cliphist stores every selection, so there is a history to go back to.
#   * wl-clip-persist fixes Wayland's actual clipboard model — the *source
#     client* owns the data, so closing the window you copied from empties the
#     clipboard. It keeps a copy alive once the owner goes away.
#
# `hypr-clip wipe` clears the history (passwords pasted by mistake, mostly);
# it is deliberately not bound to a key.
{
  flake.modules.homeManager.clipboard =
    { pkgs, ... }:
    let
      # cliphist's own list format is "<id>\t<preview>", and the id is what
      # `decode` wants — so the TSV goes to wofi with the id column hidden,
      # the same shape ./hyprland-keys.nix uses for the palette. Picking by
      # preview text alone would break on two identical copies.
      hypr-clip = pkgs.writeShellScriptBin "hypr-clip" ''
        set -eu

        cliphist=${pkgs.cliphist}/bin/cliphist

        case "''${1:-show}" in
          wipe)
            $cliphist wipe
            ${pkgs.libnotify}/bin/notify-send -u low -r 9003 \
              "Clipboard" "History cleared"
            exit 0
            ;;
        esac

        # Empty history: wofi would open an empty box with nothing to pick.
        if [ -z "$($cliphist list 2>/dev/null)" ]; then
          ${pkgs.libnotify}/bin/notify-send -u low -r 9003 \
            "Clipboard" "Nothing in the history yet"
          exit 0
        fi

        sel=$($cliphist list |
              ${pkgs.wofi}/bin/wofi --dmenu --insensitive \
                --prompt "Clipboard" --width 760 --height 480 \
                --cache-file /dev/null) || exit 0
        [ -n "$sel" ] || exit 0

        # `decode` takes the whole line back, id included.
        #
        # Images need their MIME type stated: wl-copy assumes text/plain, so a
        # screenshot pasted back from the history would arrive as the raw PNG
        # bytes rendered as mojibake. cliphist's preview for a binary entry
        # names the format — "[[ binary data 184 KiB png 1920x1080 ]]" — so it
        # is read back out of the line that was picked.
        fmt=$(printf '%s\n' "$sel" |
              ${pkgs.gnugrep}/bin/grep -oE 'binary data.*[[:space:]](png|jpe?g|gif|bmp|webp|tiff)[[:space:]]' |
              ${pkgs.gnugrep}/bin/grep -oE '(png|jpe?g|gif|bmp|webp|tiff)' | ${pkgs.coreutils}/bin/tail -1 || true)

        if [ -n "''${fmt:-}" ]; then
          if [ "$fmt" = "jpg" ]; then fmt=jpeg; fi
          printf '%s\n' "$sel" | $cliphist decode |
            ${pkgs.wl-clipboard}/bin/wl-copy --type "image/$fmt"
        else
          printf '%s\n' "$sel" | $cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
        fi
      '';
    in
    {
      home.packages = [ hypr-clip ];

      services.cliphist = {
        enable = true;

        # Screenshots are the thing most worth going back to, and hypr-shot
        # puts every one of them on the clipboard.
        allowImages = true;

        # Not graphical-session.target: GNOME's own clipboard is fine, and a
        # second watcher there would quietly record everything copied in that
        # session too.
        systemdTargets = [ "hyprland-session.target" ];
      };

      services.wl-clip-persist = {
        enable = true;

        # Regular selection only. Persisting the *primary* selection as well
        # fights middle-click paste, which hands over a new primary selection
        # on every drag-select.
        clipboardType = "regular";

        systemdTargets = [ "hyprland-session.target" ];
      };
    };
}
