# Everything every user gets.
{
  flake.modules.homeManager.base = {
    home.stateVersion = "26.05";

    # Enables the `home-manager` command in the shell
    programs.home-manager.enable = true;

    programs.git.enable = true;
  };
}
