{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.tarow.walker;
in {
  options.tarow.walker = {
    enable = lib.options.mkEnableOption "Walker";
  };

  imports = [inputs.walker.homeManagerModules.default];

  config = lib.mkIf cfg.enable {
    programs.walker = {
      enable = true;
      package = pkgs.walker;
      runAsService = true;
      config = {
        terminal = "ghostty";
        activation_mode.labels = "123456789";
        package = pkgs.walker;
        disabled = ["finder" "runner" "windows"];
        list.max_items = 20;
      };
    };
  };
}
