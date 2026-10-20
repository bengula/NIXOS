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
          { g = "Apps & session"; k = "$mod, Return"; d = "exec"; a = "kitty"; t = "Terminal"; }
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

          # Screenshots. The work is in `hypr-shot` rather than inline shell so
          # that the palette entry, the keybind and the notification it sends
          # stay one thing.
          { g = "Screenshots"; k = ", Print"; d = "exec"; a = "hypr-shot full"; t = "Whole screen — saved and copied"; label = "PrintScreen"; }
          { g = "Screenshots"; k = "$mod, Print"; d = "exec"; a = "hypr-shot region"; t = "Select a region — saved and copied"; }
          { g = "Screenshots"; k = "$mod SHIFT, Print"; d = "exec"; a = "hypr-shot window"; t = "Focused window — saved and copied"; }

          # Media
          { g = "Media"; k = ", XF86AudioRaiseVolume"; d = "exec"; a = "pamixer -i 5"; t = "Volume up"; label = "Volume up key"; }
          { g = "Media"; k = ", XF86AudioLowerVolume"; d = "exec"; a = "pamixer -d 5"; t = "Volume down"; label = "Volume down key"; }
          { g = "Media"; k = ", XF86AudioMute"; d = "exec"; a = "pamixer -t"; t = "Mute / unmute"; label = "Mute key"; }
          { g = "Media"; k = ", XF86AudioPlay"; d = "exec"; a = "playerctl --player playerctld,%any play-pause"; t = "Play / pause"; label = "Play key"; }
          { g = "Media"; k = ", XF86AudioNext"; d = "exec"; a = "playerctl --player playerctld,%any next"; t = "Next track"; label = "Next key"; }
          { g = "Media"; k = ", XF86AudioPrev"; d = "exec"; a = "playerctl --player playerctld,%any previous"; t = "Previous track"; label = "Previous key"; }
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

      # ── Lua emission ────────────────────────────────────────────────────
      # Hyprland's Lua config takes hl.bind(keyCombo, dispatcherObject, opts?) —
      # NOT the old "MOD, KEY, dispatcher, args" single string. home-manager's
      # `settings.bind` writer still emits the old single-string form, which
      # Hyprland's Lua loader rejects, so every bind silently fails to register
      # and Hyprland falls back to its built-in emergency keymap. Binds are
      # therefore emitted here as hand-written Lua via extraConfig instead of
      # going through `settings.bind`.
      luaStr = s: builtins.toJSON s; # cheap correct Lua string literal (JSON escaping matches Lua's)

      keyToLua =
        k:
        let
          parts = lib.splitString "," k;
          modsPart = builtins.replaceStrings [ "$mod" ] [ "SUPER" ] (builtins.elemAt parts 0);
          keyPart = lib.removePrefix " " (builtins.elemAt parts 1);
          mods = builtins.filter (s: s != "") (lib.splitString " " modsPart);
        in
        lib.concatStringsSep " + " (mods ++ [ keyPart ]);

      # Maps each dispatcher name + arg string used in `binds` above to the
      # equivalent hl.dsp.* call, per Hyprland's own example/hyprland.lua and
      # its Lua API docs.
      dispatcherToLua =
        b:
        let
          a = argOf b;
        in
        if b.d == "exec" then
          "hl.dsp.exec_cmd(${luaStr a})"
        else if b.d == "killactive" then
          "hl.dsp.window.close()"
        else if b.d == "togglefloating" then
          "hl.dsp.window.float({ action = \"toggle\" })"
        else if b.d == "fullscreen" then
          "hl.dsp.window.fullscreen()"
        else if b.d == "pseudo" then
          "hl.dsp.window.pseudo()"
        else if b.d == "togglesplit" then
          "hl.dsp.layout(\"togglesplit\")"
        else if b.d == "movefocus" then
          "hl.dsp.focus({ direction = ${luaStr a} })"
        else if b.d == "movewindow" then
          "hl.dsp.window.move({ direction = ${luaStr a} })"
        else if b.d == "resizeactive" then
          let
            xy = builtins.filter (s: s != "") (lib.splitString " " a);
          in
          "hl.dsp.window.resize({ x = ${builtins.elemAt xy 0}, y = ${builtins.elemAt xy 1}, relative = true })"
        else if b.d == "workspace" then
          "hl.dsp.focus({ workspace = ${luaStr a} })"
        else if b.d == "movetoworkspace" then
          "hl.dsp.window.move({ workspace = ${luaStr a} })"
        else if b.d == "togglespecialworkspace" then
          "hl.dsp.workspace.toggle_special(${luaStr a})"
        else
          throw "hyprland-keys.nix: no hl.dsp mapping for dispatcher '${b.d}' — add one in dispatcherToLua";

      toLuaBind = b: "hl.bind(${luaStr (keyToLua b.k)}, ${dispatcherToLua b})";

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

      # The second column is the same Lua the bind itself uses. `hyprctl
      # dispatch` under a Lua config evaluates its argument as Lua — the old
      # "dispatcher args" wire format parses as a syntax error and does
      # nothing — so the palette has to hand it a dispatcher object.
      rowOf = e: {
        display = "  ${pad 26 (e.label or (prettyKey e.k))}${e.t}";
        cmd = if e ? d then dispatcherToLua e else "";
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
        ${pkgs.hyprland}/bin/hyprctl dispatch "$cmd"
      '';

      # which-key style modes: show the keys, then enter the submap.
      hypr-mode = pkgs.writeShellScriptBin "hypr-mode" ''
        set -eu
        hint() { ${pkgs.libnotify}/bin/notify-send -r 9001 -t "$1" -u low "$2" "$3"; }
        # Lua config: the dispatcher is an hl.dsp.* call, not a bare word.
        submap() { ${pkgs.hyprland}/bin/hyprctl dispatch "hl.dsp.submap(\"$1\")" >/dev/null; }

        case "''${1:-reset}" in
          resize)
            hint 0 "Resize mode" "h j k l  or arrows   resize
        Shift + direction           bigger steps
        Esc  or  Return             back to normal"
            submap resize
            ;;
          window)
            hint 0 "Window mode" "h j k l  or arrows   move the window
        f fullscreen    v float     q close
        p pseudo-tile   t flip split
        Esc  or  Return             back to normal"
            submap window
            ;;
          *)
            submap reset
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
          "Log out of Hyprland")  ${pkgs.hyprland}/bin/hyprctl dispatch 'hl.dsp.exit()' ;;
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

      # Everything below goes through extraConfig as hand-written Lua, not
      # `settings.bind`/`settings.bindm` — see the note on dispatcherToLua
      # above for why the settings.bind writer can't be used here.
      wayland.windowManager.hyprland.extraConfig = ''
        ${lib.concatMapStringsSep "\n" toLuaBind binds}

        hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
        hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

        local resize = function(key, x, y, modifiers)
          local bind_key = key
          if modifiers then bind_key = modifiers .. " + " .. key end
          hl.bind(bind_key, hl.dsp.window.resize({ x = x, y = y, relative = true }), { repeating = true })
        end

        hl.define_submap("resize", function()
          resize("h", -40, 0)
          resize("l", 40, 0)
          resize("k", 0, -40)
          resize("j", 0, 40)
          resize("left", -40, 0)
          resize("right", 40, 0)
          resize("up", 0, -40)
          resize("down", 0, 40)
          resize("h", -120, 0, "SHIFT")
          resize("l", 120, 0, "SHIFT")
          resize("k", 0, -120, "SHIFT")
          resize("j", 0, 120, "SHIFT")
          hl.bind("escape", hl.dsp.submap("reset"))
          hl.bind("return", hl.dsp.submap("reset"))
        end)

        hl.define_submap("window", function()
          local move = function(key, direction)
            hl.bind(key, hl.dsp.window.move({ direction = direction }))
          end
          move("h", "l")
          move("l", "r")
          move("k", "u")
          move("j", "d")
          move("left", "l")
          move("right", "r")
          move("up", "u")
          move("down", "d")
          hl.bind("f", hl.dsp.window.fullscreen())
          hl.bind("v", hl.dsp.window.float())
          hl.bind("p", hl.dsp.window.pseudo())
          hl.bind("t", hl.dsp.layout("togglesplit"))
          hl.bind("q", hl.dsp.window.close())
          hl.bind("escape", hl.dsp.submap("reset"))
          hl.bind("return", hl.dsp.submap("reset"))
        end)
      '';
    };
}
