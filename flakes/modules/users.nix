{ config, pkgs, ... }:

{
  users.users.lovelty = {
    isNormalUser = true;
    description = "Bengula Jacob";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  users.users.bebe = {
    isNormalUser = true;
    description = "Happy Home";
    extraGroups = [ "wheel" "networkmanager" ];
  };
}

