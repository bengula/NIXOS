# wofi — the app launcher (Super + D) and the shortcut palette (Super + /).
#
# Unstyled wofi is a white box on a dark blurred desktop, which is both ugly
# and hard to read. This is written as plain config files rather than through a
# Home Manager `programs.wofi` module so it does not depend on that module
# existing in whichever home-manager revision is pinned.
{
  flake.modules.homeManager.wofi =
    { config, ... }:
    let
      palette = config.look.palette;

      # The frame rounds a little wider than the rows inside it, both off the
      # one number in ../looks/.
      frameRadius = toString (config.look.rounding + 4);
      rowRadius = toString config.look.rounding;
    in
    {
      # NOTE: no `allow_markup` — the shortcut palette contains literal "&"
      # ("Apps & session"), which Pango would reject as a bad entity.
      xdg.configFile."wofi/config".text = ''
        allow_images=true
        insensitive=true
        no_actions=true
        key_expand=Tab
      '';

      # Translucent to sit on the same frosted surface as the bar and the
      # terminal (Hyprland's `layerrule` blurs behind it). `alpha(…)` is GTK's
      # own colour function, so the see-through surfaces still come from the
      # look instead of a second hex literal drifting beside it.
      xdg.configFile."wofi/style.css".text = ''
        window {
          font-family: "JetBrainsMono Nerd Font", monospace;
          font-size: 13px;
          background-color: alpha(${palette.bg}, 0.82);
          border: 2px solid ${palette.primary};
          border-radius: ${frameRadius}px;
          color: ${palette.fg};
        }

        #input {
          margin: 10px;
          padding: 8px 12px;
          border: none;
          border-radius: ${rowRadius}px;
          background-color: alpha(${palette.overlay}, 0.55);
          color: ${palette.fg};
        }

        #input:focus {
          outline: none;
          box-shadow: none;
        }

        #inner-box, #outer-box, #scroll {
          background-color: transparent;
          border: none;
        }

        #inner-box { margin: 4px 10px 10px 10px; }

        #entry {
          padding: 6px 10px;
          border-radius: ${rowRadius}px;
        }

        /* The palette draws its group headers as plain rows starting with "──";
           they are selectable but do nothing, so they get no highlight. */
        #entry:selected {
          background-color: ${palette.primary};
          color: ${palette.bg};
        }

        #text:selected { color: ${palette.bg}; }
      '';
    };
}
