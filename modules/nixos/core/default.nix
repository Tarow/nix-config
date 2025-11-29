{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.core;
in {
  options.tarow.core = {
    enable = lib.options.mkEnableOption "Core Programs and Configs" // {default = true;};
    flakeLocation = lib.options.mkOption {
      type = lib.types.nullOr lib.types.path;
      example = "/home/user/nix-config";
      default = "/home/${config.tarow.facts.username}/nix-config";
      description = "Location of flake config. If set together with `flakeConfigKey`, an alias 'us' will be created to apply the system configuration.";
    };
    flakeConfigKey = lib.options.mkOption {
      type = lib.types.nullOr lib.types.str;
      example = "host";
      default = null;
      description = "Configuration key within the flake. If set together with `flakeLocation`, an alias 'us' will be created to apply the system configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.shellAliases.us = lib.mkIf (cfg.flakeLocation != null && cfg.flakeConfigKey != null) (lib.mkDefault "nixos-rebuild switch --flake ${cfg.flakeLocation}#${cfg.flakeConfigKey} --use-remote-sudo");
  };
}
