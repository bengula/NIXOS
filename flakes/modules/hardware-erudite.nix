# Generated hardware config stays where nixos-generate-config put it; this file
# just publishes it as an aspect so hosts.nix can pick it up like any other.
{
  flake.modules.nixos.erudite-hardware = {
    imports = [ ../hosts/erudite/hardware.nix ];

    # hardware.nix gates the Intel microcode update on this, and it defaults to
    # false — so without the line the generated config quietly does nothing.
    # It also covers the firmware Wi-Fi and Bluetooth chips need.
    hardware.enableRedistributableFirmware = true;
  };
}
