# The bar. Three things here exist for discoverability rather than decoration:
# the `hyprland/submap` module (tells you which which-key mode you are in),
# the "keys" button (opens the same palette as Super + /), and the network
# module, which is clickable rather than a readout.
#
# Volume is deliberately absent: ./dynamic-island.nix carries it with a drawer
# and a real slider, and two readouts of the same number was just noise.
{
  flake.modules.homeManager.waybar =
    { pkgs, ... }:
    let
      # Switching wifi from the bar. nmcli needs no sudo here because the user
      # is in the `networkmanager` group (see ./users.nix) — the only password
      # asked for is the network's own.
      #
      # Display strings and SSIDs travel in a TSV, the same trick
      # ./hyprland-keys.nix uses for the palette: the list wofi shows is
      # padded and decorated, and parsing an SSID back out of it would break
      # on the first network with two spaces in its name.
      hypr-wifi = pkgs.writeShellScriptBin "hypr-wifi" ''
        set -eu

        nmcli=${pkgs.networkmanager}/bin/nmcli
        wofi=${pkgs.wofi}/bin/wofi
        notify() { ${pkgs.libnotify}/bin/notify-send -r 9002 -u low "Wi-Fi" "$1"; }

        # A rescan started too soon after the last one is refused; the cached
        # scan list is fine in that case, so the failure is not fatal.
        $nmcli device wifi rescan >/dev/null 2>&1 || true

        tmp=$(${pkgs.coreutils}/bin/mktemp)
        trap '${pkgs.coreutils}/bin/rm -f "$tmp"' EXIT

        # nmcli's terse output is colon-separated and escapes a literal colon
        # inside a field as "\:" — splitting on bare colons would cut such an
        # SSID in half. Swap the escaped ones for a byte that cannot occur in
        # the output, split, then swap back.
        $nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list \
          | ${pkgs.gnused}/bin/sed 's/\\:/\x01/g' \
          | ${pkgs.gawk}/bin/awk -F: '
              { for (i = 1; i <= NF; i++) gsub(/\001/, ":", $i) }
              $2 == "" { next }           # hidden SSID — nothing to click
              !seen[$2]++ {
                mark = ($1 == "*") ? "󰸞" : "  "
                sec  = ($4 == "" || $4 == "--") ? "open" : $4
                printf "%s  %-24s  %3s%%  %s\t%s\t%s\n", mark, $2, $3, sec, $2, sec
              }' > "$tmp"

        if [ ! -s "$tmp" ]; then
          notify "No networks in range."
          exit 0
        fi

        choice=$(${pkgs.coreutils}/bin/cut -f1 "$tmp" |
                 $wofi --dmenu --prompt "Wi-Fi network" \
                   --width 460 --lines 12 --cache-file /dev/null) || exit 0
        [ -n "$choice" ] || exit 0

        row=$(${pkgs.gawk}/bin/awk -F'\t' -v c="$choice" '$1 == c { print; exit }' "$tmp")
        [ -n "$row" ] || exit 0
        ssid=$(printf '%s\n' "$row" | ${pkgs.coreutils}/bin/cut -f2)
        sec=$(printf '%s\n' "$row" | ${pkgs.coreutils}/bin/cut -f3)

        # A bare `connect` reuses whatever saved profile already carries this
        # SSID, so try it before asking for anything. Matching saved profiles
        # by name instead would be wrong: NetworkManager calls the second
        # profile it keeps for one network "Erudite 1", and this machine has
        # several such pairs. -w bounds the wait if secrets turn out to be
        # missing, which is the failure that sends us to the prompt below.
        if $nmcli -w 15 device wifi connect "$ssid" >/dev/null 2>&1; then
          notify "Connected to $ssid"
          exit 0
        fi

        # An open network had nothing left to try.
        if [ "$sec" = "open" ]; then
          notify "Could not connect to $ssid"
          exit 0
        fi

        # --password hides what is typed; dmenu with no stdin returns the
        # typed text rather than a selection.
        pass=$($wofi --dmenu --password --prompt "Password for $ssid" \
                 --width 460 --lines 1 --cache-file /dev/null < /dev/null) || exit 0
        [ -n "$pass" ] || exit 0

        if $nmcli -w 20 device wifi connect "$ssid" password "$pass" >/dev/null 2>&1; then
          notify "Connected to $ssid"
        else
          notify "Could not connect to $ssid — wrong password?"
        fi
      '';
    in
    {
      home.packages = [ hypr-wifi ];

      programs.waybar = {
        enable = true;
        # Started from Hyprland's exec-once, not a systemd unit, so there is
        # never a second bar racing the first.
        systemd.enable = false;

        settings.mainBar = {
          layer = "top";
          position = "top";
          height = 34;
          spacing = 8;

          modules-left = [
            "hyprland/workspaces"
            "hyprland/submap"
            "hyprland/window"
          ];
          modules-center = [ "clock" ];
          modules-right = [
            "custom/keys"
            "network"
            "battery"
            "tray"
          ];

          "hyprland/workspaces" = {
            format = "{id}";
            on-click = "activate";
          };

          # Shows "resize" / "window" while a mode is active.
          "hyprland/submap" = {
            format = "󰌌  {}";
            tooltip = false;
          };

          "hyprland/window" = {
            max-length = 60;
            separate-outputs = true;
          };

          clock = {
            format = "{:%a %d %b   %H:%M}";
            tooltip-format = "<tt>{calendar}</tt>";
          };

          "custom/keys" = {
            format = "󰘳  keys";
            tooltip = false;
            on-click = "hypr-keys";
          };

          network = {
            format-wifi = "󰖩  {essid}";
            format-ethernet = "󰈀  wired";
            format-disconnected = "󰖪  offline";
            tooltip-format = "{ifname}  {ipaddr}\nClick to switch network";
            on-click = "${hypr-wifi}/bin/hypr-wifi";
          };

          battery = {
            format = "{icon}  {capacity}%";
            format-charging = "󰂄  {capacity}%";
            format-icons = [
              "󰁺"
              "󰁼"
              "󰁾"
              "󰂀"
              "󰂂"
            ];
            states = {
              warning = 25;
              critical = 10;
            };
          };

          tray.spacing = 8;
        };

        # Translucent to match the terminal; Hyprland's layerrule blurs behind it.
        style = ''
          * {
            font-family: "JetBrainsMono Nerd Font", sans-serif;
            font-size: 12px;
            border: none;
            border-radius: 0;
            min-height: 0;
          }

          window#waybar {
            background: rgba(26, 27, 38, 0.72);
            color: #c0caf5;
          }

          #workspaces button {
            padding: 0 10px;
            color: #565f89;
            background: transparent;
          }

          #workspaces button.active {
            color: #1a1b26;
            background: #7aa2f7;
            border-radius: 8px;
          }

          #workspaces button:hover {
            background: rgba(122, 162, 247, 0.25);
            border-radius: 8px;
          }

          #submap {
            color: #1a1b26;
            background: #e0af68;
            padding: 0 12px;
            margin: 4px 6px;
            border-radius: 8px;
          }

          #window {
            color: #a9b1d6;
            padding: 0 8px;
          }

          #clock {
            color: #c0caf5;
            font-weight: bold;
          }

          #custom-keys {
            color: #1a1b26;
            background: rgba(187, 154, 247, 0.9);
            padding: 0 12px;
            margin: 4px 4px;
            border-radius: 8px;
          }

          #custom-keys:hover {
            background: #bb9af7;
          }

          #network,
          #battery,
          #tray {
            padding: 0 10px;
            color: #c0caf5;
          }

          #battery.warning {
            color: #e0af68;
          }

          #battery.critical {
            color: #f7768e;
          }
        '';
      };
    };
}
