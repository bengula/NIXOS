{ config, ... }:

let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.homeManager.bebe =
    { pkgs, ... }:
    {
      imports = [
        homeManager.base
        homeManager.dev
        homeManager.terminal
        homeManager.desktop
      ];

      home.username = "bebe";
      home.homeDirectory = "/home/bebe";

      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "Bengula Jacob";
            email = "kbengula@student.maseno.ac.ke";
          };
          init.defaultBranch = "main";
          pull.rebase = true;
        };
      };

      home.packages = with pkgs; [
        gnome-extension-manager
        homebank
      ];
    };
}
