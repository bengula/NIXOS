{ config, pkgs, ... }:

{
  users.users.bengula = {
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

