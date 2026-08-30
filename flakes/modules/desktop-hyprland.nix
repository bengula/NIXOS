# The Hyprland compositor itself: system packages plus the look of the session.
# Keybindings live in ./hyprland-keys.nix, the bar in ./waybar.nix.
{
  # ── System ─────────────────────────────────────────────────────────────────
  flake.modules.nixos.hyprland =
    { pkgs, ... }:
    {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };

      # Without this, hyprlock has no /etc/pam.d/hyprlock and silently falls
      # back to the "su" PAM stack to check the password.
      security.pam.services.hyprlock = { };

      environment.systemPackages = with pkgs; [
        waybar
        wofi
        hyprlock
        wl-clipboard
        grim
        slurp
        brightnessctl
        pamixer
      ];
    };

  # ── Session look & feel ────────────────────────────────────────────────────
  flake.modules.homeManager.hyprland =
    { lib, ... }:
    {
      wayland.windowManager.hyprland = {
        enable = true;

        # hyprlang is deprecated as of Hyprland 0.55 and dropped within a
        # release or two — Lua is the supported format going forward.
        configType = "lua";

        settings = {
          # Monitor — auto-detect; adjust if needed e.g. "DP-1,1920x1080@60,0x0,1"
          monitor = ",preferred,auto,1";

          exec-once = [
            "waybar"
            # The wallpaper is a systemd user service (see ./wallpaper.nix), not
            # an exec-once, so it can restart itself if the renderer dies.
            # First-run nudge: everything else is discoverable from here.
            "sleep 2 && notify-send -u low -t 9000 'Hyprland' 'Press  Super + /  for the shortcut list'"
          ];

          env = [
            "XCURSOR_SIZE,24"
            "QT_QPA_PLATFORM,wayland"
          ];

          input = {
            kb_layout = "us";
            follow_mouse = 1;
            touchpad.natural_scroll = true;
          };

          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 2;
            "col.active_border" = "rgba(7aa2f7ff) rgba(bb9af7ff) 45deg";
            "col.inactive_border" = "rgba(414868aa)";
            layout = "dwindle";
          };

          # Translucency lives or dies on the blur behind it — without this a
          # see-through terminal is just an unreadable terminal.
          decoration = {
            rounding = 10;
            blur = {
              enabled = true;
              size = 8;
              passes = 3;
              noise = 0.02;
              contrast = 1.1;
              brightness = 0.9;
              popups = true;
              new_optimizations = true;
            };
            shadow = {
              enabled = true;
              range = 18;
              render_power = 3;
              color = "rgba(0d0e14aa)";
            };
          };

          # Blur the bar, the launcher and notifications too, so the whole
          # session reads as one translucent surface.
          # Syntax note: since Hyprland 0.52 the effect needs an explicit value
          # (`blur on`, not bare `blur`), `ignorealpha` gained an underscore, and
          # the namespace is matched with `match:namespace` rather than sitting
          # as a bare trailing argument. Multiple effects can share one rule.
          layerrule = [
            "blur on, ignore_alpha 0.3, match:namespace waybar"
            "blur on, ignore_alpha 0.3, match:namespace wofi"
            "blur on, ignore_alpha 0.3, match:namespace notifications"
          ];

          # ── Animations ───────────────────────────────────────────────────
          # Durations are in 100ms units, so `5` is half a second. The rule of
          # thumb: things entering get a curve that overshoots slightly (reads as
          # weight), things leaving get a curve that accelerates away (reads as
          # fast). Same duration for both would feel sluggish on the way out.
          animations = {
            enabled = true;

            bezier = [
              "wind, 0.05, 0.9, 0.1, 1.05" # general purpose, slight spring
              "overshot, 0.13, 0.99, 0.29, 1.1" # entrances — overshoots and settles
              "smoothOut, 0.36, 0, 0.66, -0.56" # exits — pulls away quickly
              "smoothIn, 0.25, 1, 0.5, 1" # fades in gently
              "liner, 1, 1, 1, 1" # constant speed, for the border loop
            ];

            animation = [
              "windowsIn, 1, 5, overshot, slide"
              "windowsOut, 1, 4, smoothOut, slide"
              "windowsMove, 1, 4, wind"

              "border, 1, 8, default"
              # The gradient border slowly rotates. This one repaints forever —
              # delete the line if you would rather have the battery.
              "borderangle, 1, 100, liner, loop"

              "fadeIn, 1, 6, smoothIn"
              "fadeOut, 1, 4, smoothOut"
              "fadeDim, 1, 6, smoothIn"
              "fadeLayers, 1, 4, smoothIn"

              "workspaces, 1, 5, wind, slidefade 15%"
              "specialWorkspace, 1, 5, overshot, slidevert"

              # waybar, wofi and notifications slide in rather than blink on
              "layers, 1, 4, overshot, slide"
            ];
          };

          # `pseudotile` was removed in 0.55 (it had stopped doing anything).
          # The `pseudo` dispatcher and window rule are unaffected.
          dwindle = {
            preserve_split = true;
          };

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            focus_on_activate = true;
          };
        };
      };

      # Notifications are how the key hints reach the screen, so the daemon is
      # part of the compositor aspect rather than an afterthought.
      services.dunst = {
        enable = true;
        settings = {
          global = {
            width = 420;
            height = 260;
            origin = "top-right";
            offset = "16x52";
            corner_radius = 10;
            frame_width = 2;
            frame_color = "#7aa2f7";
            separator_color = "frame";
            font = "JetBrainsMono Nerd Font 10";
            markup = "full";
            format = "<b>%s</b>\\n%b";
            padding = 14;
            horizontal_padding = 16;
          };
          urgency_low = {
            background = "#1a1b26";
            foreground = "#c0caf5";
            timeout = 5;
          };
          urgency_normal = {
            background = "#1a1b26";
            foreground = "#c0caf5";
            timeout = 8;
          };
          urgency_critical = {
            background = "#1a1b26";
            foreground = "#f7768e";
            frame_color = "#f7768e";
            timeout = 0;
          };
        };
      };

      # GNOME ships its own notification daemon. Two of them on the same D-Bus
      # name means whichever wins the race gets the notifications, so dunst is
      # bound to the Hyprland session only — same treatment as the wallpaper.
      systemd.user.services.dunst = {
        Unit = {
          PartOf = lib.mkForce [ "hyprland-session.target" ];
          After = lib.mkForce [ "hyprland-session.target" ];
        };
        Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
      };
    };
}
