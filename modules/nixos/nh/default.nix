{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.nh;
  coreCfg = config.tarow.core;
in {
  options.tarow.nh = {
    enable = lib.options.mkEnableOption "nh";
  };
  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      flake = coreCfg.flakeLocation;
    };
    environment.shellAliases = lib.mkIf (coreCfg.flakeLocation != null) {
      us = lib.mkIf (coreCfg.flakeConfigKey != null) "nh os switch ${coreCfg.flakeLocation} -H ${coreCfg.flakeConfigKey}";
      update-relsat = lib.mkIf (coreCfg.flakeConfigKey != null) "nh os switch ${coreCfg.flakeLocation} -H relsat --target-host relsat.de --build-host relsat.de";
      update-homeserver = lib.mkIf (coreCfg.flakeConfigKey != null) "nh os switch ${coreCfg.flakeLocation} -H homeserver --target-host ntasler.de --build-host ntasler.de";
    };
  };
}
