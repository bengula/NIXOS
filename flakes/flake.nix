{
  description = "Erudite — NixOS, organised with the Dendritic Pattern";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # flake-parts gives us the module system *for the flake itself*.
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    # import-tree turns a directory into a list of flake-parts modules.
    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Source for the Bengula Inc portal (built reproducibly via buildNpmPackage
    # in pkgs/bengula-portal.nix). `flake = false` => plain source tree.
    bengula-portal-src = {
      url = "github:bengula/BengulaLive";
      flake = false;
    };

    # Shader wallpaper renderer, built in pkgs/orbit-wallpaper-engine.nix.
    # Pinning it as an input means the revision and its hash live in
    # flake.lock instead of being hardcoded in the derivation.
    orbit-wallpaper-src = {
      url = "github:CleanShirtUK/orbit-wallpaper-engine";
      flake = false;
    };
  };

  # ── The Dendritic Pattern ──────────────────────────────────────────────────
  #
  # This is the whole entrypoint. Every `.nix` file under ./modules is loaded
  # automatically as a flake-parts module — there is no import list to keep in
  # sync anywhere. A file becomes part of the flake by existing.
  #
  # Each file describes one *aspect* of the system (hyprland, terminal, users…)
  # and may contribute to several module classes at once:
  #
  #   flake.modules.nixos.<aspect>        → a NixOS module
  #   flake.modules.homeManager.<aspect>  → a Home Manager module
  #
  # modules/hosts.nix is where those aspects are assembled into a machine.
  #
  # NOTE: this is a git flake — Nix only sees *tracked* files. After adding a
  # new module, `git add` it before rebuilding.
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
