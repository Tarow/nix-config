{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.tarow.docker;
in
{
  imports = (import ../../../helpers/read-subdirs.nix lib ./.);

  options.tarow.docker = {
    enable = lib.options.mkEnableOption "docker";
    customNetworks = lib.options.mkOption {
      type = with lib.types; listOf str;
      example = [ ];
      default = [ ];
      description = "Custom Docker network to be created";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
    users.users.${config.wsl.defaultUser}.extraGroups = [ "docker" ];
  };
}
