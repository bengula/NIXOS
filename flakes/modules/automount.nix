# USB sticks and SD cards mount themselves, with a notification and a tray
# icon to unmount from.
#
# udisks2 is already running (GNOME needs it), so this is only the *client*
# half — the piece that watches for a new device and acts on it. Under GNOME
# that client is gvfs inside the shell, which is why removable drives already
# work there and did nothing at all under Hyprland.
#
# Bound to hyprland-session.target for the same reason: with udiskie also
# running under GNOME, two clients race to mount the same device and the loser
# logs a "device already mounted" error.
{
  flake.modules.homeManager.automount =
    { pkgs, lib, ... }:
    {
      services.udiskie = {
        enable = true;
        automount = true;
        notify = true;

        # "auto" keeps the icon out of the way until something is actually
        # mounted; the bar's `tray` module (./waybar.nix) is where it appears.
        tray = "auto";

        settings = {
          program_options = {
            # Clicking "Open" in the notification needs something to open with,
            # and udiskie's default guess (`xdg-open`) hands the directory back
            # to the handler in ./default-apps.nix — one indirection more than
            # necessary, and one that breaks if mimeapps is ever wrong.
            file_manager = lib.getExe pkgs.nautilus;
            terminal = lib.getExe pkgs.kitty;
          };
        };
      };

      systemd.user.services.udiskie = {
        Unit = {
          PartOf = lib.mkForce [ "hyprland-session.target" ];
          After = lib.mkForce [ "hyprland-session.target" ];
        };
        Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
      };
    };
}
