# The dynamic island — a floating pill under the bar that handles whatever is
# playing, the volume, and the weather.
#
# It is a *second waybar bar*, not a separate widget toolkit: one waybar
# process already runs for the main bar (started from Hyprland's exec-once in
# desktop-hyprland.nix), and adding a bar here costs nothing extra at runtime
# while inheriting the same styling, the same `layerrule` blur, and the same
# reload path as the bar in ./waybar.nix.
#
# Three things make it feel like an island rather than a second bar:
#
#   * `exclusive = false` — it reserves no space, so it floats over the
#     windows below instead of pushing them down. The compositor still keeps
#     it clear of the main bar's exclusive zone, which is what parks it
#     neatly underneath.
#   * `width` — a bar is normally the full width of the output; giving it a
#     width makes waybar centre it. That width is also the clickable region,
#     so it is kept only a little wider than the fully expanded pill.
#   * the pill itself is `.modules-center`, not the window — the window is
#     transparent, and only the centre box is painted.
#
# The "dynamic" part is two waybar drawers: hovering the track name reveals
# the skip buttons, hovering the volume icon reveals a slider. When nothing
# is playing, waybar's mpris module hides itself and the pill shrinks to just
# volume and weather.
{
  # playerctld tracks which player was last active, so "next" means the thing
  # you are actually listening to. Without it `playerctl` acts on whichever
  # player it happens to enumerate first — with Chromium, Spotify and a music
  # app all registered on MPRIS at once, that is usually the wrong one.
  flake.modules.nixos.dynamic-island = {
    services.playerctld.enable = true;
  };

  flake.modules.homeManager.dynamic-island =
    { pkgs, lib, ... }:
    let
      # "playerctld,%any": prefer the daemon's view of the active player,
      # but still work if it is not running.
      playerctl = "${pkgs.playerctl}/bin/playerctl --player playerctld,%any";

      # "" asks wttr.in to geolocate by IP, which is right for a laptop that
      # moves. Set it to a place name ("Maseno", "Kisumu") to pin it, or
      # export ISLAND_WEATHER_LOCATION to override it for one session.
      weatherLocation = "";

      # The play/pause button has to know which icon to show, and MPRIS state
      # can change without the island doing anything (a keyboard media key,
      # the player's own UI), so the icon is polled rather than toggled.
      island-playpause = pkgs.writeShellScriptBin "island-playpause" ''
        set -u
        status="$(${playerctl} status 2>/dev/null || true)"
        case "$status" in
          Playing) printf '%s\n' '{"text":"󰏤","alt":"playing","tooltip":"Pause"}' ;;
          *)       printf '%s\n' '{"text":"󰐊","alt":"paused","tooltip":"Play"}' ;;
        esac
      '';

      # Weather for the island. Everything about this is defensive: the island
      # must still render when the network is down, so a failed fetch falls
      # back to the last good payload, and no payload at all degrades to a
      # dash rather than an empty module.
      island-weather = pkgs.writeShellScriptBin "island-weather" ''
        set -u
        cache="''${XDG_CACHE_HOME:-$HOME/.cache}/island-weather.json"
        loc="''${ISLAND_WEATHER_LOCATION:-${weatherLocation}}"

        tmp="$(${pkgs.coreutils}/bin/mktemp)"
        if ${pkgs.curl}/bin/curl -sf --max-time 12 "https://wttr.in/$loc?format=j1" -o "$tmp" \
           && [ -s "$tmp" ]; then
          ${pkgs.coreutils}/bin/mv -f "$tmp" "$cache"
        else
          ${pkgs.coreutils}/bin/rm -f "$tmp"
        fi

        if [ ! -s "$cache" ]; then
          printf '%s\n' '{"text":"<span color=\"#565f89\">󰖐</span>  --","tooltip":"Weather unavailable","class":"offline"}'
          exit 0
        fi

        # wttr.in reports no day/night flag, so the hour decides which of the
        # two clear-sky icons to use.
        hour="$(${pkgs.coreutils}/bin/date +%-H)"

        ${pkgs.jq}/bin/jq -c --argjson hour "$hour" '
          def icon(code; day):
            { "113": (if day then "󰖙" else "󰖔" end),
              "116": (if day then "󰖕" else "󰼱" end),
              "119": "󰖐", "122": "󰖐", "143": "󰖑", "248": "󰖑", "260": "󰖑",
              "176": "󰖗", "263": "󰖗", "266": "󰖗", "293": "󰖗", "296": "󰖗",
              "299": "󰖖", "302": "󰖖", "305": "󰖖", "308": "󰖖",
              "311": "󰙿", "314": "󰙿", "317": "󰙿", "320": "󰼴",
              "323": "󰖘", "326": "󰖘", "329": "󰼶", "332": "󰼶", "335": "󰼶", "338": "󰼶",
              "350": "󰖒", "353": "󰖗", "356": "󰖖", "359": "󰖖", "362": "󰙿", "365": "󰙿",
              "368": "󰖘", "371": "󰼶", "374": "󰖒", "377": "󰖒",
              "386": "󰙾", "389": "󰙾", "392": "󰙾", "395": "󰙾",
              "179": "󰖘", "182": "󰙿", "185": "󰙿", "200": "󰙾",
              "227": "󰼯", "230": "󰼯", "281": "󰙿", "284": "󰙿" }[code] // "󰖐";
          def day: ($hour >= 6 and $hour < 19);
          .current_condition[0] as $c
          | (.nearest_area[0].areaName[0].value // "here") as $where
          | { text: ("<span color=\"#7dcfff\">" + icon($c.weatherCode; day) + "</span>  " + $c.temp_C + "°"),
              alt: $c.weatherDesc[0].value,
              class: "weather",
              tooltip: ( "<b>" + $where + "</b>   " + ($c.weatherDesc[0].value | ltrimstr(" ") | rtrimstr(" ")) + "\n"
                + "Feels like " + $c.FeelsLikeC + "°    Humidity " + $c.humidity + "%    Wind " + $c.windspeedKmph + " km/h"
                + (.weather[0:3] | map(
                    "\n" + icon(.hourly[4].weatherCode; true) + "  "
                    + (.date | strptime("%Y-%m-%d") | strftime("%a")) + "   "
                    + .maxtempC + "° / " + .mintempC + "°    󰖗 "
                    + ([.hourly[].chanceofrain | tonumber] | max | tostring) + "%") | join(""))
                + "\n\nClick to refresh" ) }
        ' "$cache"
      '';
    in
    {
      # playerctl is what the island's buttons (and the media keys in
      # ./hyprland-keys.nix) talk to. waybar's own mpris module only reads.
      home.packages = [
        pkgs.playerctl
        island-weather
        island-playpause
      ];

      programs.waybar.settings.island = {
        name = "island"; # → window#waybar.island in the stylesheet
        layer = "top";
        position = "top";
        exclusive = false;
        height = 30;
        width = 480;
        margin-top = 4;
        spacing = 0;

        modules-left = [ ];
        modules-center = [
          "group/island-media"
          "group/island-sound"
          "custom/weather"
        ];
        modules-right = [ ];

        # In a drawer group the first module is always visible and the rest
        # slide out from behind it on hover.
        "group/island-media" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 350;
            children-class = "island-btn";
            transition-left-to-right = true;
          };
          modules = [
            "mpris"
            "custom/prev"
            "custom/playpause"
            "custom/next"
          ];
        };

        "group/island-sound" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 350;
            children-class = "island-slider";
            transition-left-to-right = true;
          };
          modules = [
            "pulseaudio"
            "pulseaudio/slider"
          ];
        };

        # Covers anything that speaks MPRIS — mpv, VLC, Spotify, and video in
        # Chrome or Firefox alike.
        mpris = {
          format = "{player_icon}  {dynamic}";
          format-paused = "{status_icon}  <i>{dynamic}</i>";
          # Some players (GNOME Decibels among them) report "stopped" for a
          # track that is merely sitting there loaded; without this the island
          # would swallow its own play button in that state.
          format-stopped = "{status_icon}  <i>{dynamic}</i>";
          dynamic-order = [
            "title"
            "artist"
          ];
          dynamic-separator = "  ·  ";
          dynamic-len = 18;
          # Follow playerctld rather than letting waybar latch onto whichever
          # player it enumerates first — with several registered (and stale
          # Chromium instances among them) that pick is close to random, and a
          # dead one leaves the island blank. The icon is the generic one as a
          # result: playerctld reports itself, not the app behind it.
          player = "playerctld";
          interval = 1;
          player-icons = {
            default = "󰎆";
            mpv = "󰕧";
            vlc = "󰕧";
            chromium = "󰐌";
            chrome = "󰐌";
            firefox = "󰈹";
            spotify = "󰓇";
          };
          status-icons = {
            paused = "󰏤";
            stopped = "󰓛";
          };
          tooltip-format = "{player}\n{title}\n{artist}";
          on-click = "${playerctl} play-pause";
          on-click-middle = "${playerctl} next";
          on-scroll-up = "${playerctl} next";
          on-scroll-down = "${playerctl} previous";
        };

        "custom/prev" = {
          format = "󰒮";
          tooltip = false;
          on-click = "${playerctl} previous";
        };

        "custom/playpause" = {
          format = "{}";
          return-type = "json";
          exec = "${island-playpause}/bin/island-playpause";
          interval = 1;
          on-click = "${playerctl} play-pause";
        };

        "custom/next" = {
          format = "󰒭";
          tooltip = false;
          on-click = "${playerctl} next";
        };

        pulseaudio = {
          format = "<span color=\"#7aa2f7\">{icon}</span>  {volume}%";
          format-muted = "<span color=\"#565f89\">󰝟</span>  off";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
            headphone = "󰋋";
            headset = "󰋎";
          };
          tooltip-format = "{desc}";
          on-click = "pamixer -t";
          on-scroll-up = "pamixer -i 5";
          on-scroll-down = "pamixer -d 5";
        };

        "pulseaudio/slider" = {
          min = 0;
          max = 100;
          orientation = "horizontal";
        };

        "custom/weather" = {
          format = "{}";
          return-type = "json";
          exec = "${island-weather}/bin/island-weather";
          interval = 900;
          # Clicking asks waybar to re-run the module now rather than waiting
          # out the rest of the 15-minute interval.
          signal = 9;
          on-click = "pkill -RTMIN+9 waybar";
          tooltip = true;
        };
      };

      # Appended to ./waybar.nix's stylesheet — one waybar process, one sheet.
      # Every island rule is scoped under `window#waybar.island` so none of it
      # can reach the main bar, whose own rules (`#pulseaudio`, `*`, …) would
      # otherwise collide with these.
      programs.waybar.style = lib.mkAfter ''
        /* ── Dynamic island ──────────────────────────────────────────── */

        /* The bar is invisible; only the pill in the middle is painted. */
        window#waybar.island {
          background: transparent;
        }

        window#waybar.island .modules-center {
          background: rgba(16, 17, 27, 0.88);
          border: 1px solid rgba(122, 162, 247, 0.18);
          border-radius: 15px;
          padding: 0 2px;
          color: #c0caf5;
          transition: border-color 250ms ease, background 250ms ease;
        }

        window#waybar.island .modules-center:hover {
          border-color: rgba(122, 162, 247, 0.45);
          background: rgba(16, 17, 27, 0.94);
        }

        window#waybar.island #mpris,
        window#waybar.island #pulseaudio,
        window#waybar.island #custom-weather {
          padding: 0 10px;
          color: #c0caf5;
        }

        window#waybar.island #mpris.paused,
        window#waybar.island #mpris.stopped {
          color: #565f89;
        }

        window#waybar.island #pulseaudio.muted {
          color: #565f89;
        }

        /* Hairlines between the three segments. */
        window#waybar.island #pulseaudio,
        window#waybar.island #custom-weather {
          border-left: 1px solid rgba(192, 202, 245, 0.12);
        }

        /* Revealed on hover: play/pause between the two skip buttons. */
        window#waybar.island #custom-prev,
        window#waybar.island #custom-playpause,
        window#waybar.island #custom-next {
          color: #7aa2f7;
          padding: 0 7px;
          margin: 4px 1px;
          border-radius: 11px;
          transition: background 150ms ease;
        }

        window#waybar.island #custom-playpause {
          color: #bb9af7;
          padding: 0 8px;
        }

        window#waybar.island #custom-prev:hover,
        window#waybar.island #custom-playpause:hover,
        window#waybar.island #custom-next:hover {
          background: rgba(122, 162, 247, 0.22);
          color: #c0caf5;
        }

        /* Revealed on hover: the volume slider. */
        window#waybar.island .island-slider {
          padding: 0 10px 0 2px;
        }

        window#waybar.island #pulseaudio-slider trough {
          min-width: 64px;
          min-height: 6px;
          border-radius: 3px;
          background: rgba(192, 202, 245, 0.20);
        }

        window#waybar.island #pulseaudio-slider highlight {
          min-height: 6px;
          border-radius: 3px;
          background: #7aa2f7;
        }

        window#waybar.island #pulseaudio-slider slider {
          background: transparent;
          min-width: 0;
          min-height: 0;
        }

        /* Tooltips are their own windows and cannot be scoped to one bar, so
           this styles the main bar's tooltips to match as well. */
        tooltip {
          background: rgba(16, 17, 27, 0.96);
          border: 1px solid rgba(122, 162, 247, 0.35);
          border-radius: 12px;
        }

        tooltip label {
          color: #c0caf5;
          padding: 4px;
        }
      '';
    };
}
