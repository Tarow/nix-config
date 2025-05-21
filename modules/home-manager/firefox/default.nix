{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.firefox;
in {
  options.tarow.firefox = {
    enable = lib.options.mkEnableOption "firefox";
  };
  config = lib.mkIf cfg.enable {
    programs.firefox.enable = true;
    programs.firefox.profiles.default = {

    };
    stylix.targets.firefox.profileNames = ["default"];
  };
}
