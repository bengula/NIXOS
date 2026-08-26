{ config, ... }:

let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.homeManager.pri =
    { pkgs, ... }:
    {
      imports = [
        homeManager.base
        homeManager.terminal
      ];

      home.username = "pri";
      home.homeDirectory = "/home/pri";

      home.packages = with pkgs; [
        thunderbird
      ];
    };
}
