# GNOME Terminal, translucent.
#
# GNOME Terminal keeps its profiles in dconf rather than a config file, so the
# profile UUID is pinned to keep this reproducible across rebuilds.
let
  profile = "b1dcc9dd-5262-4d8d-a863-c897e6d979b9";
in
{
  flake.modules.nixos.terminal =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.gnome-terminal ];

      # dconf must be available for the Home Manager profile below to stick.
      programs.dconf.enable = true;
    };

  flake.modules.homeManager.terminal = {
    dconf.settings = {
      "org/gnome/desktop/default-applications/terminal" = {
        exec = "gnome-terminal";
        exec-arg = "";
      };

      "org/gnome/terminal/legacy" = {
        theme-variant = "dark";
        menu-accelerator-enabled = false;
      };

      "org/gnome/terminal/legacy/profiles:" = {
        default = profile;
        list = [ profile ];
      };

      "org/gnome/terminal/legacy/profiles:/:${profile}" = {
        visible-name = "Tokyo Night";

        # ── Translucency ─────────────────────────────────────────────────
        # `use-theme-transparency` must be off or the GTK theme wins and the
        # percentage below is ignored. 0 = opaque, 100 = invisible; ~22 reads
        # as glass against Hyprland's blur without losing contrast on text.
        use-theme-transparency = false;
        use-transparent-background = true;
        background-transparency-percent = 22;

        # ── Colours ──────────────────────────────────────────────────────
        use-theme-colors = false;
        foreground-color = "#c0caf5";
        background-color = "#1a1b26";
        bold-color-same-as-fg = true;
        cursor-colors-set = true;
        cursor-background-color = "#c0caf5";
        cursor-foreground-color = "#1a1b26";
        palette = [
          "#15161e"
          "#f7768e"
          "#9ece6a"
          "#e0af68"
          "#7aa2f7"
          "#bb9af7"
          "#7dcfff"
          "#a9b1d6"
          "#414868"
          "#f7768e"
          "#9ece6a"
          "#e0af68"
          "#7aa2f7"
          "#bb9af7"
          "#7dcfff"
          "#c0caf5"
        ];

        # ── Comfort ──────────────────────────────────────────────────────
        use-system-font = false;
        font = "JetBrainsMono Nerd Font 11";
        cell-height-scale = 1.1;
        audible-bell = false;
        scrollbar-policy = "never";
        scrollback-lines = 20000;
        default-size-columns = 110;
        default-size-rows = 30;
        cursor-shape = "block";
        cursor-blink-mode = "on";
      };
    };
  };
}
