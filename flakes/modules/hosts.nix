# Machines. This is the only file that says which aspects a host is made of.
{ config, inputs, ... }:

let
  inherit (config.flake.modules) nixos;
in
{
  flake.nixosConfigurations.Erudite = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };

    modules = [
      # Hardware & boot
      nixos.erudite-hardware
      nixos.boot

      # System
      nixos.locale
      nixos.networking
      nixos.bluetooth
      nixos.nix-settings
      nixos.packages
      nixos.users

      # Desktop
      nixos.gnome
      nixos.hyprland
      nixos.portals
      nixos.terminal
      nixos.dynamic-island

      # Users' environments
      nixos.home-manager

      # Services
      nixos.bengula-portal

      # ── Host-specific ────────────────────────────────────────────────────
      {
        # Bengula Inc portal (production). Uncomment and fill in to serve the
        # site over HTTPS. Requires DNS for the domain to point here, and the
        # npmDepsHash in ../pkgs/bengula-portal.nix to be filled in.
        #
        # services.bengulaPortal = {
        #   enable = true;
        #   domain = "bengula.co.ke";
        #   acmeEmail = "admin@bengula.co.ke";
        #   environmentFile = "/var/lib/bengula/secrets.env";  # GEMINI_API_KEY=…
        # };

        # REQUIRED – never change after first install
        system.stateVersion = "26.05";
      }
    ];
  };
}
