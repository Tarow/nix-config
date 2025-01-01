{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.hyprland;
in {
  options.tarow.hyprland = {
    enable = lib.options.mkEnableOption "Hyprland";
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };

    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
  };
}
