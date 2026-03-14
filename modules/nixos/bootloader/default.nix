{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.bootLoader;
in {
  options.tarow.bootLoader = {
    enable = lib.options.mkEnableOption "Bootloader Config";
  };

  config = lib.mkIf cfg.enable {
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
