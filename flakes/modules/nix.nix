{
  flake.modules.nixos.nix-settings = {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      substituters = [ "https://cache.nixos.org/" ];
      max-jobs = "auto";

      # This is a git flake, so every rebuild with an uncommitted change prints
      # a "Git tree is dirty" warning. That is the normal state while editing.
      warn-dirty = false;

      # ── Downloading over a slow link ─────────────────────────────────────
      # The defaults assume a fat pipe: 25 parallel connections to
      # cache.nixos.org, and a stalled connection is given a full 5 minutes
      # before it is retried. On a thin link those 25 streams split the
      # bandwidth until every one of them drops under the stall threshold, and
      # then the rebuild spends 5 minutes at a time doing nothing —
      # "Less than 1 bytes/sec transferred the last 300 seconds".
      # Fewer connections each get a usable share, and a stall is abandoned in
      # 45s rather than 300.
      http-connections = 8;
      connect-timeout = 15;
      stalled-download-timeout = 45;
    };

    nixpkgs.config.allowUnfree = true;

    nix.gc = {
      automatic = true;
      dates = "03:15";
      options = "--delete-older-than 21d";
    };
  };
}
