{ ... }:

{
  # GNOME Terminal stores profiles in dconf rather than a conventional config
  # file.  Use a fixed profile ID so this remains reproducible across rebuilds.
  dconf.settings = {
    "org/gnome/terminal/legacy/profiles:" = {
      default = "b1dcc9dd-5262-4d8d-a863-c897e6d979b9";
      list = [ "b1dcc9dd-5262-4d8d-a863-c897e6d979b9" ];
    };

    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      visible-name = "Tokyo Night";
      use-theme-colors = false;
      foreground-color = "#c0caf5";
      background-color = "#1a1b26";
      palette = [
        "#15161e" "#f7768e" "#9ece6a" "#e0af68"
        "#7aa2f7" "#bb9af7" "#7dcfff" "#a9b1d6"
        "#414868" "#f7768e" "#9ece6a" "#e0af68"
        "#7aa2f7" "#bb9af7" "#7dcfff" "#c0caf5"
      ];
      use-transparent-background = true;
      background-transparency-percent = 18;
    };
  };
}
