{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.ghostty;
in {
  options.tarow.ghostty = {
    enable = lib.options.mkEnableOption "Ghostty";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.ghostty];
    xdg.configFile."ghostty/config".text = lib.generators.toKeyValue {} {
      font-size = 11;
      copy-on-select = "clipboard";
      shell-integration-features = "cursor,sudo,no-title";
      app-notifications = "no-clipboard-copy";
    };
  };
}
