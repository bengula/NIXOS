# Everything every user gets.
{ config, ... }:

let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.homeManager.base = {
    # Declares `look` — the option every surface in the session reads its
    # colours from. It lives here rather than in the desktop list because the
    # option has to be declared exactly once per user, and this is the one
    # aspect every user imports.
    imports = [ homeManager.look ];

    home.stateVersion = "26.05";

    # Enables the `home-manager` command in the shell
    programs.home-manager.enable = true;

    programs.git.enable = true;
  };
}
