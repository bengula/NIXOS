# Keybindings — and the key *suggestions* that go with them.
#
# The list below is the single source of truth. It generates three things at
# once, so the hints can never drift from the actual bindings:
#
#   1. Hyprland's `bind` lines.
#   2. `hypr-keys`  — Super + / — a searchable palette; pressing Enter on an
#      entry actually runs it, so the shortcut list doubles as a command menu.
#   3. `hypr-mode`  — which-key style modes that put the available keys on
#      screen while you are in them (waybar shows the mode name too).
{
  flake.modules.homeManager.hyprland-keys =
    { pkgs, lib, ... }:
    let
      workspaces = builtins.genList (i: i + 1) 10; # 1 … 10
      wsKey = n: if n == 10 then "0" else toString n;

      # ── Single source of truth ─────────────────────────────────────────
      binds =
        [
          # Apps & session
          { g = "Apps & session"; k = "$mod, Return"; d = "exec"; a = "gnome-terminal"; t = "Terminal"; }
          { g = "Apps & session"; k = "$mod, D"; d = "exec"; a = "wofi --show drun"; t = "App launcher"; }
          { g = "Apps & session"; k = "$mod, E"; d = "exec"; a = "nautilus"; t = "Files"; }
          { g = "Apps & session"; k = "$mod, B"; d = "exec"; a = "google-chrome-stable"; t = "Browser"; }
          { g = "Apps & session"; k = "$mod, Q"; d = "killactive"; t = "Close focused window"; }
          { g = "Apps & session"; k = "$mod, F"; d = "fullscreen"; t = "Fullscreen"; }
          { g = "Apps & session"; k = "$mod, V"; d = "togglefloating"; t = "Float / unfloat"; }
          { g = "Apps & session"; k = "$mod, P"; d = "pseudo"; t = "Pseudo-tile"; }
          { g = "Apps & session"; k = "$mod, T"; d = "togglesplit"; t = "Flip split direction"; }
          { g = "Apps & session"; k = "$mod, Escape"; d = "exec"; a = "hypr-lock"; t = "Lock screen"; }
          { g = "Apps & session"; k = "$mod SHIFT, R"; d = "exec"; a = "hyprctl reload"; t = "Reload Hyprland config"; }
          # Not `exit` directly: Super+M is one slip away from Super+N and used
          # to end the session with no way back.
          { g = "Apps & session"; k = "$mod, M"; d = "exec"; a = "hypr-exit"; t = "Exit Hyprland (asks first)"; }
          { g = "Apps & session"; k = "$mod, slash"; d = "exec"; a = "hypr-keys"; t = "Show this list (Enter runs an entry)"; label = "Super + /"; }
          { g = "Apps & session"; k = "$mod, F1"; d = "exec"; a = "hypr-keys"; t = "Show this list"; hide = true; }

          # Modes — press once, then use single keys
          { g = "Modes"; k = "$mod, R"; d = "exec"; a = "hypr-mode resize"; t = "Resize mode — keys shown on screen"; }
          { g = "Modes"; k = "$mod, W"; d = "exec"; a = "hypr-mode window"; t = "Window mode — keys shown on screen"; }

          # Focus
          { g = "Focus"; k = "$mod, h"; d = "movefocus"; a = "l"; t = "Focus left"; }
          { g = "Focus"; k = "$mod, j"; d = "movefocus"; a = "d"; t = "Focus down"; }
          { g = "Focus"; k = "$mod, k"; d = "movefocus"; a = "u"; t = "Focus up"; }
          { g = "Focus"; k = "$mod, l"; d = "movefocus"; a = "r"; t = "Focus right"; }
          { g = "Focus"; k = "$mod, left"; d = "movefocus"; a = "l"; t = "Focus left"; hide = true; }
          { g = "Focus"; k = "$mod, right"; d = "movefocus"; a = "r"; t = "Focus right"; hide = true; }
          { g = "Focus"; k = "$mod, up"; d = "movefocus"; a = "u"; t = "Focus up"; hide = true; }
          { g = "Focus"; k = "$mod, down"; d = "movefocus"; a = "d"; t = "Focus down"; hide = true; }

          # Move window
          { g = "Move window"; k = "$mod SHIFT, h"; d = "movewindow"; a = "l"; t = "Move window left"; }
          { g = "Move window"; k = "$mod SHIFT, j"; d = "movewindow"; a = "d"; t = "Move window down"; }
          { g = "Move window"; k = "$mod SHIFT, k"; d = "movewindow"; a = "u"; t = "Move window up"; }
          { g = "Move window"; k = "$mod SHIFT, l"; d = "movewindow"; a = "r"; t = "Move window right"; }
          { g = "Move window"; k = "$mod SHIFT, left"; d = "movewindow"; a = "l"; t = "Move window left"; hide = true; }
          { g = "Move window"; k = "$mod SHIFT, right"; d = "movewindow"; a = "r"; t = "Move window right"; hide = true; }
          { g = "Move window"; k = "$mod SHIFT, up"; d = "movewindow"; a = "u"; t = "Move window up"; hide = true; }
          { g = "Move window"; k = "$mod SHIFT, down"; d = "movewindow"; a = "d"; t = "Move window down"; hide = true; }

          # Resize
          { g = "Resize"; k = "$mod CTRL, h"; d = "resizeactive"; a = "-40 0"; t = "Narrower"; }
          { g = "Resize"; k = "$mod CTRL, l"; d = "resizeactive"; a = "40 0"; t = "Wider"; }
          { g = "Resize"; k = "$mod CTRL, k"; d = "resizeactive"; a = "0 -40"; t = "Shorter"; }
          { g = "Resize"; k = "$mod CTRL, j"; d = "resizeactive"; a = "0 40"; t = "Taller"; }
          { g = "Resize"; k = "$mod CTRL, left"; d = "resizeactive"; a = "-40 0"; t = "Narrower"; hide = true; }
          { g = "Resize"; k = "$mod CTRL, right"; d = "resizeactive"; a = "40 0"; t = "Wider"; hide = true; }
          { g = "Resize"; k = "$mod CTRL, up"; d = "resizeactive"; a = "0 -40"; t = "Shorter"; hide = true; }
          { g = "Resize"; k = "$mod CTRL, down"; d = "resizeactive"; a = "0 40"; t = "Taller"; hide = true; }

          # Workspaces
          { g = "Workspaces"; k = "$mod, Tab"; d = "workspace"; a = "e+1"; t = "Next workspace"; }
          { g = "Workspaces"; k = "$mod SHIFT, Tab"; d = "workspace"; a = "e-1"; t = "Previous workspace"; }
          { g = "Workspaces"; k = "$mod, S"; d = "togglespecialworkspace"; a = "magic"; t = "Toggle scratchpad"; }
          { g = "Workspaces"; k = "$mod SHIFT, S"; d = "movetoworkspace"; a = "special:magic"; t = "Send window to scratchpad"; }

          # Screenshots. The work is in `hypr-shot` rather than inline shell:
          # the palette re-runs these commands through `hyprctl dispatch`, which
          # does not preserve quoting, so anything with a "$(…)" in it has to be
          # a single word here.
          { g = "Screenshots"; k = ", Print"; d = "exec"; a = "hypr-shot full"; t = "Whole screen — saved and copied"; label = "PrintScreen"; }
          { g = "Screenshots"; k = "$mod, Print"; d = "exec"; a = "hypr-shot region"; t = "Select a region — saved and copied"; }
          { g = "Screenshots"; k = "$mod SHIFT, Print"; d = "exec"; a = "hypr-shot window"; t = "Focused window — saved and copied"; }

          # Media
          { g = "Media"; k = ", XF86AudioRaiseVolume"; d = "exec"; a = "pamixer -i 5"; t = "Volume up"; label = "Volume up key"; }
          { g = "Media"; k = ", XF86AudioLowerVolume"; d = "exec"; a = "pamixer -d 5"; t = "Volume down"; label = "Volume down key"; }
          { g = "Media"; k = ", XF86AudioMute"; d = "exec"; a = "pamixer -t"; t = "Mute / unmute"; label = "Mute key"; }
          { g = "Media"; k = ", XF86MonBrightnessUp"; d = "exec"; a = "brightnessctl set 10%+"; t = "Brightness up"; label = "Brightness up key"; }
          { g = "Media"; k = ", XF86MonBrightnessDown"; d = "exec"; a = "brightnessctl set 10%-"; t = "Brightness down"; label = "Brightness down key"; }
        ]
        # Workspaces 1–10: bound, but folded into two lines in the palette.
        ++ lib.concatMap (n: [
          { g = "Workspaces"; k = "$mod, ${wsKey n}"; d = "workspace"; a = toString n; t = "Workspace ${toString n}"; hide = true; }
          { g = "Workspaces"; k = "$mod SHIFT, ${wsKey n}"; d = "movetoworkspace"; a = toString n; t = "Send window to workspace ${toString n}"; hide = true; }
        ]) workspaces;

      # Lines that appear in the palette but are not bindings of their own.
      docs = [
        { g = "Focus"; label = "Super + Arrows"; t = "Focus in that direction"; }
        { g = "Move window"; label = "Super + Shift + Arrows"; t = "Move window that way"; }
        { g = "Resize"; label = "Super + Ctrl + Arrows"; t = "Resize the focused window"; }
        { g = "Workspaces"; label = "Super + 1 to 0"; t = "Switch to workspace 1–10"; }
        { g = "Workspaces"; label = "Super + Shift + 1 to 0"; t = "Send window to workspace 1–10"; }
        { g = "Mouse"; label = "Super + drag"; t = "Move a window"; }
        { g = "Mouse"; label = "Super + right-drag"; t = "Resize a window"; }
      ];

      # ── Derivation of everything else ──────────────────────────────────
      argOf = b: b.a or "";
      toBind = b: if argOf b == "" then "${b.k}, ${b.d}" else "${b.k}, ${b.d}, ${argOf b}";

      prettyKey =
        k:
        let
          withMods = builtins.replaceStrings
            [ "$mod SHIFT" "$mod CTRL" "$mod ALT" "$mod" ]
            [ "Super+Shift" "Super+Ctrl" "Super+Alt" "Super" ]
            k;
          joined = builtins.replaceStrings [ ", " ] [ "+" ] withMods;
        in
        builtins.replaceStrings [ "+" ] [ " + " ] (lib.removePrefix "+" joined);

      pad =
        n: s:
        let
          gap = n - builtins.stringLength s;
        in
        s + lib.concatStrings (lib.genList (_: " ") (if gap > 0 then gap else 1));

      groups = [
        "Apps & session"
        "Modes"
        "Focus"
        "Move window"
        "Resize"
        "Workspaces"
        "Screenshots"
        "Media"
        "Mouse"
      ];

      entries = builtins.filter (e: !(e.hide or false)) (binds ++ docs);

      rowOf = e: {
        display = "  ${pad 26 (e.label or (prettyKey e.k))}${e.t}";
        cmd = if e ? d then "${e.d} ${argOf e}" else "";
      };

      block =
        g:
        let
          inGroup = builtins.filter (e: e.g == g) entries;
        in
        lib.optionals (inGroup != [ ]) (
          [
            {
              display = "──  ${g}";
              cmd = "";
            }
          ]
          ++ map rowOf inGroup
        );

      rows = lib.concatMap block groups;

      # display <TAB> dispatcher-and-args
      keymap = pkgs.writeText "hypr-keys.tsv" (
        lib.concatMapStringsSep "\n" (r: "${r.display}\t${r.cmd}") rows + "\n"
      );

      hypr-keys = pkgs.writeShellScriptBin "hypr-keys" ''
        set -eu
        map=${keymap}
        sel=$(cut -f1 "$map" | ${pkgs.wofi}/bin/wofi --dmenu --insensitive \
                --prompt "Hyprland shortcuts" --width 820 --height 600 \
                --cache-file /dev/null) || exit 0
        # Match on the trimmed label so a launcher that strips padding still works.
        cmd=$(${pkgs.gawk}/bin/awk -F'\t' -v s="$sel" \
              'function tr(x) { gsub(/^[ \t]+|[ \t]+$/, "", x); return x }
               tr($1) == tr(s) { print $2; exit }' "$map")
        [ -n "$cmd" ] || exit 0
        ${pkgs.hyprland}/bin/hyprctl dispatch $cmd
      '';

      # which-key style modes: show the keys, then enter the submap.
      hypr-mode = pkgs.writeShellScriptBin "hypr-mode" ''
        set -eu
        hint() { ${pkgs.libnotify}/bin/notify-send -r 9001 -t "$1" -u low "$2" "$3"; }
        dispatch() { ${pkgs.hyprland}/bin/hyprctl dispatch "$@" >/dev/null; }

        case "''${1:-reset}" in
          resize)
            hint 0 "Resize mode" "h j k l  or arrows   resize
        Shift + direction           bigger steps
        Esc  or  Return             back to normal"
            dispatch submap resize
            ;;
          window)
            hint 0 "Window mode" "h j k l  or arrows   move the window
        f fullscreen    v float     q close
        p pseudo-tile   t flip split
        Esc  or  Return             back to normal"
            dispatch submap window
            ;;
          *)
            dispatch submap reset
            hint 900 "Normal mode" " "
            ;;
        esac
      '';

      # Screenshots. Always both saved and copied — needing to remember which
      # key does which is the thing that makes screenshots annoying.
      # Filenames avoid ":" so they survive being copied to a FAT/exFAT stick.
      hypr-shot = pkgs.writeShellScriptBin "hypr-shot" ''
        set -eu
        dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
        ${pkgs.coreutils}/bin/mkdir -p "$dir"
        file="$dir/$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S).png"

        case "''${1:-full}" in
          region)
            # Cancelling slurp (Esc) must leave no empty file behind.
            geom=$(${pkgs.slurp}/bin/slurp) || exit 0
            ${pkgs.grim}/bin/grim -g "$geom" "$file"
            ;;
          window)
            geom=$(${pkgs.hyprland}/bin/hyprctl activewindow -j |
                   ${pkgs.jq}/bin/jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
            ${pkgs.grim}/bin/grim -g "$geom" "$file"
            ;;
          *)
            ${pkgs.grim}/bin/grim "$file"
            ;;
        esac

        ${pkgs.wl-clipboard}/bin/wl-copy --type image/png < "$file"
        ${pkgs.libnotify}/bin/notify-send -t 5000 -i "$file" \
          'Screenshot' "Copied to the clipboard — saved in $dir"
      '';

      # Super + M used to end the session on the first press. It now asks, and
      # defaults to the harmless answer.
      hypr-exit = pkgs.writeShellScriptBin "hypr-exit" ''
        set -eu
        answer=$(printf 'Cancel\nLock the screen\nLog out of Hyprland\n' |
                 ${pkgs.wofi}/bin/wofi --dmenu --prompt "End the session?" \
                   --width 380 --height 200 --cache-file /dev/null) || exit 0
        case "$answer" in
          "Lock the screen")      hypr-lock ;;
          "Log out of Hyprland")  ${pkgs.hyprland}/bin/hyprctl dispatch exit ;;
          *)                      exit 0 ;;
        esac
      '';
    in
    {
      home.packages = [
        hypr-keys
        hypr-mode
        hypr-shot
        hypr-exit
        pkgs.libnotify
      ];

      wayland.windowManager.hyprland.settings = {
        "$mod" = "SUPER";

        bind = map toBind binds;

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };

      # Submaps are order-sensitive, so they are written as raw config rather
      # than through `settings`. waybar's hyprland/submap module shows which
      # one is active, and hypr-mode puts the key list on screen.
      wayland.windowManager.hyprland.extraConfig = ''
        # ── Resize mode  (Super + R) ──────────────────────────────────────
        submap = resize
        binde = , h, resizeactive, -40 0
        binde = , l, resizeactive, 40 0
        binde = , k, resizeactive, 0 -40
        binde = , j, resizeactive, 0 40
        binde = , left, resizeactive, -40 0
        binde = , right, resizeactive, 40 0
        binde = , up, resizeactive, 0 -40
        binde = , down, resizeactive, 0 40
        binde = SHIFT, h, resizeactive, -120 0
        binde = SHIFT, l, resizeactive, 120 0
        binde = SHIFT, k, resizeactive, 0 -120
        binde = SHIFT, j, resizeactive, 0 120
        bind = , escape, exec, hypr-mode reset
        bind = , return, exec, hypr-mode reset
        submap = reset

        # ── Window mode  (Super + W) ──────────────────────────────────────
        submap = window
        bind = , h, movewindow, l
        bind = , l, movewindow, r
        bind = , k, movewindow, u
        bind = , j, movewindow, d
        bind = , left, movewindow, l
        bind = , right, movewindow, r
        bind = , up, movewindow, u
        bind = , down, movewindow, d
        bind = , f, fullscreen
        bind = , v, togglefloating
        bind = , p, pseudo
        bind = , t, togglesplit
        bind = , q, killactive
        bind = , escape, exec, hypr-mode reset
        bind = , return, exec, hypr-mode reset
        submap = reset
      '';
    };
}
