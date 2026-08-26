# Lock screen (Super + Escape) and the idle timeline that leads to it.
#
# hyprlock drives its own animation tree, separate from Hyprland's — the
# lock/unlock fade and the input field's reactions are configured here, not in
# the compositor. Node names come from hyprlock's animation tree:
# global → fade → { fadeIn, fadeOut } and global → inputField → inputFieldColors.
{
  flake.modules.homeManager.lock =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      # Super + Escape runs this rather than hyprlock directly, so the shader
      # wallpaper can animate out behind the lock screen and sweep back in on
      # unlock. Every wallpaper signal is optional and time-bounded — with no
      # renderer running this is just hyprlock with two no-ops around it.
      hypr-lock = pkgs.writeShellScriptBin "hypr-lock" ''
        set -eu
        control="''${XDG_CACHE_HOME:-$HOME/.cache}/orbit-wallpaper-engine/control"

        signal() {
          [ -p "$control" ] || return 0
          ${pkgs.coreutils}/bin/timeout 0.5s \
            sh -c 'printf "%s\n" "$1" > "$2"' sh "$1" "$control" >/dev/null 2>&1 || true
        }

        ${config.programs.hyprlock.package}/bin/hyprlock &
        lock=$!

        # Let hyprlock grab its screenshot of the live desktop first, then
        # reset the wallpaper behind it.
        ${pkgs.coreutils}/bin/sleep 0.4
        signal exit

        # Tell logind the session is locked, so LockedHint and the Lock signal
        # match reality however the lock was triggered. This is done here rather
        # than by binding Super + Escape straight to `loginctl lock-session`,
        # because that would make the lock key silently do nothing whenever
        # hypridle is not running. Sending it *after* hyprlock is up means
        # hypridle's `pidof hyprlock ||` guard swallows the resulting Lock
        # signal instead of racing a second lock screen onto the display.
        ${pkgs.systemd}/bin/loginctl lock-session || true

        wait "$lock" || true

        # Nothing else clears the hint, so without this an idle lock would leave
        # the session marked locked for the rest of the uptime.
        ${pkgs.systemd}/bin/loginctl unlock-session || true
        signal intro
      '';
    in
    {
      home.packages = [ hypr-lock ];

      programs.hyprlock = {
        enable = true;

        settings = {
          general = {
            disable_loading_bar = true;
            hide_cursor = true;
            ignore_empty_input = true;
            # Draw the first frame before showing anything, so locking never
            # flashes an unstyled screen.
            immediate_render = true;
          };

          # ── The lock / unlock transition ─────────────────────────────────
          animations = {
            enabled = true;

            bezier = [
              "snappy, 0.2, 0.9, 0.1, 1.0"
              "liner, 1, 1, 1, 1"
            ];

            animation = [
              # Locking fades in a touch slower than unlocking fades out — the
              # way in should feel deliberate, the way back to work should not.
              "fadeIn, 1, 5, snappy"
              "fadeOut, 1, 3, snappy"
              # Input field recolouring on check / fail / caps-lock.
              "inputFieldColors, 1, 2, snappy"
            ];
          };

          background = [
            {
              monitor = "";
              path = "screenshot";
              blur_passes = 3;
              blur_size = 8;
              vibrancy = 0.17;
              vibrancy_darkness = 0.2;
              brightness = 0.75;
            }
          ];

          input-field = [
            {
              monitor = "";
              size = "300, 52";
              position = "0, -50";
              halign = "center";
              valign = "center";
              outline_thickness = 2;
              rounding = 26;
              dots_size = 0.24;
              dots_spacing = 0.32;
              dots_center = true;
              outer_color = "rgba(7aa2f7cc)";
              inner_color = "rgba(1a1b2699)";
              font_color = "rgb(c0caf5)";
              check_color = "rgba(e0af68cc)";
              fail_color = "rgba(f7768ecc)";
              placeholder_text = "<span foreground='##8a92b2'>Password…</span>";
              fail_text = "<span foreground='##f7768e'>$FAIL ($ATTEMPTS)</span>";
              fade_on_empty = false;
              shadow_passes = 2;
              shadow_size = 6;
            }
          ];

          label = [
            # Clock
            {
              monitor = "";
              text = "$TIME";
              font_family = "JetBrainsMono Nerd Font";
              font_size = 88;
              color = "rgba(c0caf5ee)";
              position = "0, 90";
              halign = "center";
              valign = "center";
              shadow_passes = 2;
              shadow_size = 8;
            }
            # Date
            {
              monitor = "";
              text = "cmd[update:60000] date +'%A, %d %B'";
              font_family = "JetBrainsMono Nerd Font";
              font_size = 18;
              color = "rgba(a9b1d6cc)";
              position = "0, 20";
              halign = "center";
              valign = "center";
            }
            # Who is logged in
            {
              monitor = "";
              text = "$USER";
              font_family = "JetBrainsMono Nerd Font";
              font_size = 14;
              color = "rgba(7aa2f7cc)";
              position = "0, -110";
              halign = "center";
              valign = "center";
            }
          ];
        };
      };

      # ── Idle timeline ─────────────────────────────────────────────────────
      # Without this the screen never locks or blanks on its own. The steps are
      # deliberately staged so nothing happens without a warning you can undo by
      # touching the machine: dim first, lock a while later, blank last.
      services.hypridle = {
        enable = true;

        settings = {
          general = {
            # loginctl lock-session is the single entry point, so the lid
            # switch, `loginctl lock-session` and the idle timer all take the
            # same path through hypr-lock.
            lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || ${hypr-lock}/bin/hypr-lock";
            before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
            after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          };

          listener = [
            # 5 min — dim. `-s` saves the current level so `-r` restores it.
            {
              timeout = 300;
              on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10%";
              on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
            }
            # 10 min — lock.
            {
              timeout = 600;
              on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
            }
            # 15 min — screen off.
            {
              timeout = 900;
              on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
              on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
            }
          ];
        };
      };

      # GNOME does its own idle handling, so hypridle must not run in a GNOME
      # session — bind it to Hyprland's target the same way the wallpaper is.
      systemd.user.services.hypridle = {
        Unit = {
          PartOf = lib.mkForce [ "hyprland-session.target" ];
          After = lib.mkForce [ "hyprland-session.target" ];
        };
        Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
      };
    };
}
