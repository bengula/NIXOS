{ config, ... }:

let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.homeManager.lovelty =
    { pkgs, ... }:
    {
      imports = [
        homeManager.base
        homeManager.terminal
        homeManager.desktop
      ];

      home.username = "lovelty";
      home.homeDirectory = "/home/lovelty";

      home.packages = with pkgs; [
        thunderbird
      ];
    };
}
