# wofi — the app launcher (Super + D) and the shortcut palette (Super + /).
#
# Unstyled wofi is a white box on a dark blurred desktop, which is both ugly
# and hard to read. This is written as plain config files rather than through a
# Home Manager `programs.wofi` module so it does not depend on that module
# existing in whichever home-manager revision is pinned.
{
  flake.modules.homeManager.wofi = {
    # NOTE: no `allow_markup` — the shortcut palette contains literal "&"
    # ("Apps & session"), which Pango would reject as a bad entity.
    xdg.configFile."wofi/config".text = ''
      allow_images=true
      insensitive=true
      no_actions=true
      key_expand=Tab
    '';

    # Tokyo Night, translucent to sit on the same frosted surface as the bar
    # and the terminal (Hyprland's `layerrule` blurs behind it).
    xdg.configFile."wofi/style.css".text = ''
      window {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 13px;
        background-color: rgba(26, 27, 38, 0.82);
        border: 2px solid #7aa2f7;
        border-radius: 14px;
        color: #c0caf5;
      }

      #input {
        margin: 10px;
        padding: 8px 12px;
        border: none;
        border-radius: 10px;
        background-color: rgba(65, 72, 104, 0.55);
        color: #c0caf5;
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
        border-radius: 10px;
      }

      /* The palette draws its group headers as plain rows starting with "──";
         they are selectable but do nothing, so they get no highlight. */
      #entry:selected {
        background-color: #7aa2f7;
        color: #1a1b26;
      }

      #text:selected { color: #1a1b26; }
    '';
  };
}
