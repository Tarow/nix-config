{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.tarow.gaming;
in {
  options.tarow.oomd = {
    enable = lib.options.mkEnableOption "oomd";
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      oomd = {
        enable = true;

        # Fedora enables these options by default. See the 10-oomd-* files here:
        # https://src.fedoraproject.org/rpms/systemd/tree/acb90c49c42276b06375a66c73673ac3510255
        enableRootSlice = true;
        enableUserSlices = true;
        enableSystemSlice = true;
        settings.OOM.DefaultMemoryPressureDurationSec = "20s";
      };

      services.nix-daemon.serviceConfig.OOMScoreAdjust = 350;

      tmpfiles.settings."10-oomd-root".w = {
        # Enables storing of the kernel log (including stack trace) into pstore upon a panic or crash.
        "/sys/module/kernel/parameters/crash_kexec_post_notifiers" = {
          age = "-";
          argument = "Y";
        };
      };
    };
  };
}
