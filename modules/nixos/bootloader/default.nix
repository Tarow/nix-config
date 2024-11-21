{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.tarow.bootLoader;
in
{
  options.tarow.bootLoader = {
    enable = lib.options.mkEnableOption "Bootloader Config";
  };

  config = lib.mkIf cfg.enable {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
