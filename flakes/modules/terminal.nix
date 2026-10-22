# Kitty terminal, translucent and reproducible.
#
# The ANSI slots are this user's look (../looks/), so `ls` colours, prompts
# and diffs come out in the session's own colours rather than in whichever
# sixteen a program assumes.
{
  flake.modules.nixos.terminal =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.kitty ];
    };

  flake.modules.homeManager.terminal =
    { config, ... }:
    let
      palette = config.look.palette;
    in
    {
      programs.kitty = {
        enable = true;

        settings = {
          background = palette.bg;
          background_opacity = "0.78";
          foreground = palette.fg;
          cursor = palette.fg;
          cursor_text_color = palette.bg;
          font_family = "JetBrainsMono Nerd Font";
          font_size = 11;
          disable_ligatures = "never";
          scrollback_lines = 20000;
          enable_audio_bell = false;
          confirm_os_window_close = 1;

          color0 = palette.bgDeep;
          color1 = palette.alarm;
          color2 = palette.success;
          color3 = palette.attention;
          # The "blue" slot is where directories, prompts and most CLI accents
          # land, so it carries the look's primary.
          color4 = palette.primary;
          color5 = palette.secondary;
          color6 = palette.info;
          color7 = palette.fgSoft;
          color8 = palette.overlay;
          color9 = palette.alarm;
          color10 = palette.success;
          color11 = palette.attention;
          color12 = palette.primary;
          color13 = palette.secondary;
          color14 = palette.info;
          color15 = palette.fg;
        };
      };
    };
}
