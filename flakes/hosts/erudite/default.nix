{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules
  ];

  networking.hostName = "Erudite";

  # ── Bengula Inc portal (production) ─────────────────────────────────────────
  # Uncomment and fill in to serve the site over HTTPS. Requires DNS for the
  # domain to point at this host, and the npmDepsHash in
  # ../../pkgs/bengula-portal.nix to be filled in (see that file).
  #
  # services.bengulaPortal = {
  #   enable = true;
  #   domain = "bengula.co.ke";
  #   acmeEmail = "admin@bengula.co.ke";
  #   environmentFile = "/var/lib/bengula/secrets.env";  # GEMINI_API_KEY=…  (optional)
  # };

  # REQUIRED – never change after first install
  system.stateVersion = "26.05";
}

