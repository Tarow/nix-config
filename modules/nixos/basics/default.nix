{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.tarow.basics;
in
{
  options.tarow.basics = {
    enable = lib.options.mkEnableOption "Basic Programs and Configs";
    configLocation = lib.options.mkOption {
      type = lib.types.nullOr lib.types.str;
      example = "~/nix-config#host";
      default = null;
      description = "Location of the hosts config. If set, an alias 'us' will be created to apply the system configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.shellAliases.us = lib.mkIf (cfg.configLocation != null) "sudo nixos-rebuild switch --flake ${cfg.configLocation}";
  };
}
