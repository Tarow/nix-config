{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.docker;
in {
  options.tarow.docker = {
    enable = lib.options.mkEnableOption "Docker";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
