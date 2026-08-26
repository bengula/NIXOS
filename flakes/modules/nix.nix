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
    };

    nixpkgs.config.allowUnfree = true;

    nix.gc = {
      automatic = true;
      dates = "03:15";
      options = "--delete-older-than 21d";
    };
  };
}
