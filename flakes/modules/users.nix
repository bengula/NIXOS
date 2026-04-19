{ config, pkgs, ... }:

{
  users.users.pri = {
    isNormalUser = true;
    description = "Princess";
    extraGroups = [ "wheel" "networkmanager" "video" "adbusers" "bluetooth"];
  };

  users.users.bebe = {
    isNormalUser = true;
    description = "Happy Home";
    extraGroups = [ "wheel" "networkmanager" "video" "adbusers" "bluetooth"];
  };
}
