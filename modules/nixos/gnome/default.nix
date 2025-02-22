{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.gnome;
in {
  options.tarow.gnome = {
    enable = lib.options.mkEnableOption "Gnome";
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
#      enable = true;
      displayManager.gdm.enable = true;
   #   displayManager.gdm.wayland = false;
      desktopManager.gnome.enable = true;
    };
  };
}
