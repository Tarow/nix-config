{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.ghostty;
in {
  options.tarow.ghostty = {
    enable = lib.options.mkEnableOption "Ghostty";
    package = lib.options.mkOption {
      default = inputs.ghostty.packages.${pkgs.system}.default;
      type = lib.types.package;
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];
    xdg.configFile."ghostty/config".text = lib.generators.toKeyValue {} {
      font-size = 11;
      theme = "ayu";
      copy-on-select = "clipboard";
      shell-integration-features = "cursor,sudo,no-title";
    };
  };
}
