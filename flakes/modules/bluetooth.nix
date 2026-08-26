{
  flake.modules.nixos.bluetooth = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      # ── Experimental is OFF on purpose ───────────────────────────────────
      # It runs bluetoothd with the LE Audio / ISO socket paths enabled, which
      # Ubuntu does not do. Those paths are the least-tested part of the stack
      # on pre-2013 adapters and are the first suspect for the machine cutting
      # power on connect. Turn it back on only to reproduce the fault, or if
      # you need battery-level reporting on a headset:
      #
      #   settings.General.Experimental = true;
      #
      # `Enable = "Source,Sink,Media,Socket"` was dropped with it — that key is
      # a leftover from BlueZ 4's audio.conf and does nothing in main.conf.
    };

    # Blueman gives D-Bus integration and Polkit permissions — needed for
    # non-root users in the 'bluetooth' group.
    services.blueman.enable = true;
  };
}
