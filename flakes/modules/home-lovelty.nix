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

      # Pink instead of the default Tokyo Night — the whole session follows
      # from this one line, bar and launcher and lock screen included, and it
      # changes nothing for the other users of the same aspects.
      look = import ../looks/blossom.nix { inherit pkgs; };

      home.packages = with pkgs; [
        thunderbird
      ];
    };
}
