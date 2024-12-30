{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.keyboard;
in {
  options.tarow.keyboard = {
    enable = lib.options.mkEnableOption "Keyboard Settings";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.xkb.layout = "eu";
  };
}
