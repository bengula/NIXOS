{
  flake.modules.nixos.boot = {
    boot.loader.grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };
  };
}
