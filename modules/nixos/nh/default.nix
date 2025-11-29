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
    environment.shellAliases.us = lib.mkIf (coreCfg.flakeLocation != null && coreCfg.flakeConfigKey != null) "nh os switch ${coreCfg.flakeLocation} -C ${coreCfg.flakeConfigKey}";
  };
}
