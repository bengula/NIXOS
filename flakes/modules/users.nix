{
  flake.modules.nixos.users =
    { pkgs, ... }:
    {
      users.users.lovelty = {
        isNormalUser = true;
        description = "Princess";

        # Pinned deliberately. Renaming a user in NixOS does NOT rename the
        # account: changing the attribute name creates a *new* user with a
        # freshly allocated uid and orphans the old home directory, which is
        # how /home/lovelty was left stranded at uid 1002 once before. Pinning
        # the uid to the one the account already has keeps every file in
        # /home/lovelty owned by its own user across rebuilds.
        uid = 1003;
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
