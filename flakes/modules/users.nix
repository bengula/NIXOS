{ config, pkgs, ... }:

{
  users.users.lovelty = {
    isNormalUser = true;
    description = "Winnie Jacob";
    extraGroups = [ "wheel" "networkmanager" "video" "adbusers" "bluetooth"];
  };

  users.users.bebe = {
    isNormalUser = true;
    description = "Happy Home";
    extraGroups = [ "wheel" "networkmanager" "video" "adbusers" "bluetooth"];
  };
}

