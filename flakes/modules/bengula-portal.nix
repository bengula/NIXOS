# The portal's NixOS module is long and self-contained, so it stays in its own
# file outside this tree; here it is just published as an aspect.
{
  flake.modules.nixos.bengula-portal = {
    imports = [ ../services/bengula-portal.nix ];
  };
}
