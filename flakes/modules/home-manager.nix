# Wires Home Manager into NixOS and maps each user to their aspect.
{ config, inputs, ... }:

let
  inherit (config.flake.modules) homeManager;
in
{
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };

      # Without this, the first rebuild that wants to write a file a user
      # already has (say ~/.config/wofi/style.css) aborts the whole activation
      # with "would be clobbered". With it, the old file is moved aside and the
      # rebuild goes through.
      backupFileExtension = "hm-bak";

      users.bebe.imports = [ homeManager.bebe ];
      users.pri.imports = [ homeManager.pri ];
    };
  };
}
