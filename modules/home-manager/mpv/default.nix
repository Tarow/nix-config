{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.mpv;
in {
  options.tarow.mpv = {
    enable = lib.options.mkEnableOption "mpv";
  };
  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      bindings = {
        "k" = "seek -15";
        "j" = "seek 15";
      };
    };
  };
}
