{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.tarow.docker;
in
{
  imports = lib.tarow.readSubdirs ./.;

  options.tarow.docker = {
    enable = lib.options.mkEnableOption "docker";
    stackDir = lib.options.mkOption {
      type = lib.types.str;
      default = "./docker";
      description = "Base directory for compose stacks. Relative to $HOME";
    };
    customNetworks = lib.options.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Custom Docker network to be created";
    };
  };

  config = lib.mkIf cfg.enable { };
}
