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
    users.users.${config.tarow.facts.username}.extraGroups = ["docker"];
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = false;
        setSocketVariable = false;
      };
    };
  };
}
