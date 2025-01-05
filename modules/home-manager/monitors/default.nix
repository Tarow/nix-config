{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.monitors;

  monitorConfig =
    if (cfg.configuration == null)
    then null
    else
      (
        if (lib.isString cfg.configuration)
        then (pkgs.writeText "monitors.xml" cfg.configuration)
        else cfg.configuration
      );
in {
  options.tarow.monitors = {
    configuration = lib.options.mkOption {
      type = with lib.types; nullOr (either str path);
      default = null;
    };
  };

  config = lib.mkIf (cfg.configuration != null) {
    xdg.configFile."monitors.xml".source = monitorConfig;
  };
}
