{
  flake.modules.nixos.users =
    { pkgs, ... }:
    {
      users.users.pri = {
        isNormalUser = true;
        description = "Princess";
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "adbusers"
          "bluetooth"
        ];
      };

      users.users.bebe = {
        isNormalUser = true;
        description = "Happy Home";
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "adbusers"
          "bluetooth"
        ];
      };
    };
}
