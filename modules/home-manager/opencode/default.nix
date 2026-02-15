{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.opencode;
in {
  options.tarow.opencode = {
    enable = lib.options.mkEnableOption "opencode";
  };
  config = lib.mkIf cfg.enable {
    home.shellAliases.oc = "opencode";
    programs.opencode = {
      enable = true;
      # TODO
      # ...
    };
  };
}
