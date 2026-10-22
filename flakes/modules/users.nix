{
  flake.modules.nixos.users =
    { pkgs, ... }:
    {
      # Both users listed "adbusers" and "bluetooth" here for a long time and
      # neither ever applied — no such group exists on this system, so NixOS
      # silently dropped them and `id` never showed them. Do not add them back:
      #
      #   adbusers  — gone from NixOS. `programs.adb` is a mkRemovedOptionModule
      #               now ("no longer needed as systemd 258 handles uaccess
      #               rules automatically"); setting it is a build error. This
      #               machine runs systemd 261, and adb reaches a plugged-in
      #               device off `android-tools` in packages.nix alone.
      #   bluetooth — never existed in NixOS at all; nothing declares it.
      #               Managing adapters is a polkit grant to the active local
      #               session, which is what services.blueman.enable in
      #               bluetooth.nix provides.
      #
      # So the fix for "user X cannot reach bluetooth/adb" is never a group.
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
        ];
      };
    };
}
