# The bar. Two things here exist for discoverability rather than decoration:
# the `hyprland/submap` module (tells you which which-key mode you are in) and
# the "keys" button (opens the same palette as Super + /).
{
  flake.modules.homeManager.waybar = {
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
          "pulseaudio"
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

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "󰝟  muted";
          format-icons.default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
          on-click = "pamixer -t";
          on-scroll-up = "pamixer -i 5";
          on-scroll-down = "pamixer -d 5";
        };

        network = {
          format-wifi = "󰖩  {essid}";
          format-ethernet = "󰈀  wired";
          format-disconnected = "󰖪  offline";
          tooltip-format = "{ifname}  {ipaddr}";
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

        #pulseaudio,
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
