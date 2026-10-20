# Shell, editor and the CLI tools that go with them.
{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      programs.fish.enable = true;

      programs.starship = {
        enable = true;
        enableFishIntegration = true;
      };

      programs.neovim = {
        enable = true;
        # Both default to true below stateVersion 26.05 and false above it.
        # Pinned to the new value: nothing here uses the Ruby or Python remote
        # plugin providers, and they drag a full Ruby and Python closure into
        # every rebuild — which matters on a slow link.
        withRuby = false;
        withPython3 = false;
      };

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      home.packages = with pkgs; [
        fd
        ripgrep
        eza
      ];
    };
}
