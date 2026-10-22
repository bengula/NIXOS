# The thing that answers "Authentication required".
#
# `security.polkit` is already on (GNOME pulls it in), but polkit only *asks*
# through an authentication agent registered by the session — and nothing
# registers one under Hyprland. The symptom is not an error: blueman's pairing
# dialog, mounting a system disk from Nautilus and anything else that needs a
# password simply does nothing at all.
#
# Bound to hyprland-session.target rather than the graphical session Home
# Manager would use by default (`wayland.systemd.target`): a session can only
# have one registered agent, and gnome-shell registers its own, so leaving this
# on graphical-session.target means the two race for the registration every
# GNOME login. Same treatment as dunst in ./desktop-hyprland.nix.
{
  flake.modules.homeManager.polkit =
    { lib, ... }:
    {
      services.hyprpolkitagent.enable = true;

      systemd.user.services.hyprpolkitagent = {
        Unit = {
          PartOf = lib.mkForce [ "hyprland-session.target" ];
          After = lib.mkForce [ "hyprland-session.target" ];
        };
        Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
      };
    };
}
