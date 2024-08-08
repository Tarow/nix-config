{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.tarow.docker;
in
{
  options.tarow.docker = {
    enable = lib.options.mkEnableOption "docker";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}
