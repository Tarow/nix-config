{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.nh;
  coreCfg = config.tarow.core;
  isStandalone = !config.submoduleSupport.enable;
in {
  options.tarow.nh = {
    enable = lib.options.mkEnableOption "nh";
  };
  config = lib.mkIf cfg.enable {
    home.file."isStandalone".text =
      if isStandalone
      then "true"
      else "false";
    programs.nh = {
      enable = true;
      flake = coreCfg.flakeLocation;
    };
    home.shellAliases.uh = lib.mkIf (isStandalone && coreCfg.flakeLocation != null && coreCfg.flakeConfigKey != null) "nh home switch ${coreCfg.flakeLocation} -c ${coreCfg.flakeConfigKey}";
  };
}
