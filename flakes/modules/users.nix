{ config, pkgs, ... }:

{
  users.users.lovelty = {
    isNormalUser = true;
    description = "Winnie Jacob";
    home = "/home/lovelty";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  users.users.bebe = {
    isNormalUser = true;
    description = "Happy Home";
    extraGroups = [ "wheel" "networkmanager" ];
  };
}

