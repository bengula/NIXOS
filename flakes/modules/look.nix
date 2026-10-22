# How a user's session looks, as one option they can swap wholesale.
#
# Nine aspects paint something — kitty, the bar, the island, wofi, dunst, the
# window borders, the lock screen, the recorder pill, the shader wallpaper —
# and they are shared between every Hyprland user, so a hex literal anywhere
# in them would be the same hex for everybody. They read `config.look`
# instead, and a user picks their look in their own file:
#
#   look = import ../looks/blossom.nix { inherit pkgs; };
#
# which is how `bebe` stays on Tokyo Night while `lovelty` is pink without a
# second copy of a single stylesheet existing anywhere.
#
# `types.attrs` rather than a submodule of typed sub-options: a definition
# *replaces* the default here rather than merging into it, which is what makes
# a look a thing you read end to end in ../looks/ instead of a diff against
# another look. The cost is that a look missing an attribute fails as a
# missing-attribute error at build time rather than as a typed option error —
# loud either way, which is the part that matters.
#
# The option is declared on ./home-base.nix so that every user has it exactly
# once, whether or not they log into Hyprland.
{
  flake.modules.homeManager.look =
    { pkgs, lib, ... }:
    {
      options.look = lib.mkOption {
        type = lib.types.attrs;
        default = import ../looks/tokyonight.nix { inherit pkgs; };
        defaultText = lib.literalExpression "import ../looks/tokyonight.nix { inherit pkgs; }";
        description = ''
          This user's whole appearance: `palette` (the colours, by role),
          `rounding`, `font`, `cursor`, `accent`, `lockGlyph` and
          `wallpaperStrength`. See ../looks/tokyonight.nix for the shape — a
          look must define all of it.
        '';
      };
    };
}
