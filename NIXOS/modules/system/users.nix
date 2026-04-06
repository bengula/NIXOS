{ config, pkgs, ... }:

{
  users.users.lovelty = {
    isNormalUser = true;
    description = "Winnie Jacob";
    extraGroups = [ "wheel" "networkmanager" "video" "adbusers" "bluetooth"];
  };

  users.users.bengula = {
    isNormalUser = true;
    description = "Bengula Jacob";
    extraGroups = [ "wheel" "networkmanager" "video" "adbusers" "bluetooth"];
  };
}
