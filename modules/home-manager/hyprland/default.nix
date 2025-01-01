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
    programs.hyprland = {
      enable = true;
    };
  };
}
