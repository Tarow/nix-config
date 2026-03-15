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
    environment.shellAliases = lib.mkIf (cfg.flakeLocation != null) {
      us = lib.mkIf (cfg.flakeConfigKey != null) (lib.mkDefault "nixos-rebuild switch --flake ${cfg.flakeLocation}#${cfg.flakeConfigKey} --sudo");
      update-relsat = lib.mkIf (cfg.flakeConfigKey != null) (lib.mkDefault "nixos-rebuild switch --flake ${cfg.flakeLocation}#relsat --sudo --target-host relsat.de --build-host relsat.de");
      update-homeserver = lib.mkIf (cfg.flakeConfigKey != null) (lib.mkDefault "nixos-rebuild switch --flake ${cfg.flakeLocation}#homeserver --sudo --target-host ntasler.de --build-host ntasler.de");
    };
  };
}
