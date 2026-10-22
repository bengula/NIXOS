# The Hyprland compositor itself: system packages plus the look of the session.
# Keybindings live in ./hyprland-keys.nix, the bar in ./waybar.nix, the
# colours in ../looks/ (reached through `config.look`).
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
    { lib, config, ... }:
    let
      inherit (import ../looks/syntax.nix) hypr;
      palette = config.look.palette;
    in
    {
      wayland.windowManager.hyprland = {
        enable = true;

        configType = "lua";
      };

      # Everything here is hand-written Lua, not `settings`. Home Manager's
      # Lua renderer for `settings` emits calls that do not exist in
      # Hyprland's real Lua API — hl.general(...), hl.decoration(...),
      # hl.input(...), hl.misc(...), hl.dwindle(...) and hl.layerrule(...)
      # are all fabricated; the real API only has a single hl.config({...})
      # taking nested tables (see hl.meta.lua / the example hyprland.lua
      # shipped in the hyprland package's share/hypr/). hl.monitor and
      # hl.env also take a different shape than the `settings` writer
      # produces. Any one of those calls erroring aborts the whole Lua
      # chunk before it reaches the keybinds below it, which is why this
      # used to look like "no keybinds work except the Hyprland-internal
      # emergency Super+M" — the config never finished loading.
      wayland.windowManager.hyprland.extraConfig = ''
        -- Monitor. HDMI-A-1 (the Hitachi panel) is pinned explicitly because
        -- its EDID is wrong about itself: the basic block flags 1024x768 as
        -- the "preferred" timing, so `mode = "preferred"` left the whole
        -- session at 1024x768 and cut content off the screen. Detailed timing
        -- #2 in that same EDID is a real 1920x1080@60 (148.5 MHz) mode and
        -- the panel drives it correctly — verified live via
        --   hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1 })'
        -- (`hyprctl keyword` does not work here — this is a Lua config.)
        -- GNOME reaches the same panel as "HDMI-1" and needs the matching
        -- resolution in ~/.config/monitors.xml, which mutter owns; that file
        -- is deliberately not managed from here so GNOME's own Display panel
        -- stays usable.
        hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1 })

        -- Catch-all for anything else plugged in. `highres` rather than
        -- `preferred` for the reason above: an EDID's preferred flag is not
        -- trustworthy, and picking the largest mode is the failure mode that
        -- does not hide content.
        hl.monitor({ output = "", mode = "highres", position = "auto", scale = "auto" })

        -- The cursor size is the look's (./theme.nix sets the GTK/X11 side
        -- from the same number), and Wayland clients that read the env var
        -- rather than the cursor theme have to agree with it, or the pointer
        -- changes size as the mouse crosses between them.
        hl.env("XCURSOR_SIZE", "${toString config.look.cursor.size}")
        hl.env("QT_QPA_PLATFORM", "wayland")

        hl.config({
          input = {
            kb_layout = "us",
            follow_mouse = 1,
            touchpad = { natural_scroll = true },
          },

          general = {
            gaps_in = 5,
            gaps_out = 10,
            border_size = 2,
            col = {
              active_border = { colors = { "${hypr palette.primary "ff"}", "${hypr palette.secondary "ff"}" }, angle = 45 },
              inactive_border = "${hypr palette.overlay "aa"}",
            },
            layout = "dwindle",
          },

          -- Translucency lives or dies on the blur behind it — without this a
          -- see-through terminal is just an unreadable terminal.
          decoration = {
            -- The look's one corner radius; the bar's pills and the
            -- launcher's frame are derived from the same number.
            rounding = ${toString config.look.rounding},
            blur = {
              enabled = true,
              size = 8,
              passes = 3,
              noise = 0.02,
              contrast = 1.1,
              brightness = 0.9,
              popups = true,
              new_optimizations = true,
            },
            shadow = {
              enabled = true,
              range = 18,
              render_power = 3,
              color = "${hypr palette.shadow "aa"}",
            },
          },

          -- `pseudotile` was removed in 0.55 (it had stopped doing anything).
          -- The `pseudo` dispatcher and window rule are unaffected.
          dwindle = {
            preserve_split = true,
          },

          misc = {
            disable_hyprland_logo = true,
            disable_splash_rendering = true,
            focus_on_activate = true,
          },
        })

        -- Blur the bar, the launcher and notifications too, so the whole
        -- session reads as one translucent surface.
        hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 0.3 })
        hl.layer_rule({ match = { namespace = "wofi" }, blur = true, ignore_alpha = 0.3 })
        hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.3 })

        -- Animations use the Hyprland 0.56 Lua API directly. The Home Manager
        -- Lua renderer currently emits the old, nonexistent hl.animations(...).
        hl.config({ animations = { enabled = true } })

        hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
        hl.curve("overshot", { type = "bezier", points = { { 0.13, 0.99 }, { 0.29, 1.1 } } })
        hl.curve("smoothOut", { type = "bezier", points = { { 0.36, 0 }, { 0.66, -0.56 } } })
        hl.curve("smoothIn", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })
        hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })

        hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "overshot", style = "slide" })
        hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "smoothOut", style = "slide" })
        hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "wind" })
        hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "default" })
        hl.animation({ leaf = "borderangle", enabled = true, speed = 100, bezier = "liner", style = "loop" })
        hl.animation({ leaf = "fadeIn", enabled = true, speed = 6, bezier = "smoothIn" })
        hl.animation({ leaf = "fadeOut", enabled = true, speed = 4, bezier = "smoothOut" })
        hl.animation({ leaf = "fadeDim", enabled = true, speed = 6, bezier = "smoothIn" })
        hl.animation({ leaf = "fadeLayers", enabled = true, speed = 4, bezier = "smoothIn" })
        hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "wind", style = "slidefade 15%" })
        hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "overshot", style = "slidevert" })
        hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "overshot", style = "slide" })

        hl.on("hyprland.start", function()
          hl.exec_cmd("waybar")
          hl.exec_cmd("sleep 2 && notify-send -u low -t 9000 'Hyprland' 'Press  Super + /  for the shortcut list'")
        end)
      '';

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
            corner_radius = config.look.rounding;
            frame_width = 2;
            frame_color = palette.primary;
            separator_color = "frame";
            font = "JetBrainsMono Nerd Font 10";
            markup = "full";
            format = "<b>%s</b>\\n%b";
            padding = 14;
            horizontal_padding = 16;
          };
          urgency_low = {
            background = palette.bg;
            foreground = palette.fg;
            timeout = 5;
          };
          urgency_normal = {
            background = palette.bg;
            foreground = palette.fg;
            timeout = 8;
          };
          urgency_critical = {
            background = palette.bg;
            foreground = palette.alarm;
            frame_color = palette.alarm;
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
