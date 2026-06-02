# Production deployment for the Bengula Inc portal:
#   • a hardened systemd service running the Express server (Nix-built package)
#   • nginx reverse proxy on 80/443 with automatic Let's Encrypt TLS
#
# Enable + configure it from the host (see hosts/erudite/default.nix):
#
#   services.bengulaPortal = {
#     enable = true;
#     domain = "bengula.co.ke";
#     acmeEmail = "admin@bengula.co.ke";
#     environmentFile = "/var/lib/bengula/secrets.env";   # holds GEMINI_API_KEY=…
#   };
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.services.bengulaPortal;

  # Build the portal from the source flake input. npmDepsHash lives in the
  # package file and must be filled in on first build (see comments there).
  portal = pkgs.callPackage ../pkgs/bengula-portal.nix {
    src = inputs.bengula-portal-src;
  };
in
{
  options.services.bengulaPortal = {
    enable = lib.mkEnableOption "the Bengula Inc production portal";

    domain = lib.mkOption {
      type = lib.types.str;
      example = "bengula.co.ke";
      description = "Public domain served over HTTPS by nginx.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Localhost port the Node server binds to (proxied by nginx).";
    };

    acmeEmail = lib.mkOption {
      type = lib.types.str;
      example = "admin@bengula.co.ke";
      description = "Contact email for Let's Encrypt / ACME registration.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/var/lib/bengula/secrets.env";
      description = ''
        Optional systemd EnvironmentFile with runtime secrets, e.g.

          GEMINI_API_KEY=your-key-here

        Keep this file OUT of the Nix store (manage it with agenix/sops, or
        create it manually with 0600 perms). Without it, the AI coach falls
        back to the built-in simulated responses.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.bengula-portal = {
      description = "Bengula Inc portal (Express server)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      environment = {
        NODE_ENV = "production";
        PORT = toString cfg.port;
      };

      serviceConfig = {
        # Wrapper (from the package) pins cwd + NODE_ENV; PORT comes from the
        # `environment` block above.
        ExecStart = lib.getExe portal;
        Restart = "on-failure";
        RestartSec = 5;

        # ── Sandboxing / hardening ──────────────────────────────────────────
        DynamicUser = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        # AF_UNIX + AF_NETLINK are needed for glibc DNS/NSS resolution of
        # outbound HTTPS (e.g. the Gemini API).
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
        RestrictNamespaces = true;
        LockPersonality = true;
        SystemCallFilter = [ "@system-service" ];
        SystemCallErrorNumber = "EPERM";
        # Node's JIT needs writable+executable memory, so we do NOT set
        # MemoryDenyWriteExecute.
      }
      # Secrets (GEMINI_API_KEY, etc.) — only when an env file is configured.
      // lib.optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;

      virtualHosts.${cfg.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = cfg.acmeEmail;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
