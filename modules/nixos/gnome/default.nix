{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.tarow.gnome;
in
{
  options.tarow.gnome = {
    enable = lib.options.mkEnableOption "Gnome";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
  };
}