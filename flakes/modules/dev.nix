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

      programs.neovim.enable = true;

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
