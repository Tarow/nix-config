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
  };
  config = lib.mkIf cfg.enable {
    home.packages = [inputs.ghostty.packages.x86_64-linux.default];
    xdg.configFile."ghostty/config".text = lib.generators.toKeyValue {} {
      font-size = 11;
      theme = "ayu";
      copy-on-select = "clipboard";
      shell-integration-features = "cursor,sudo,no-title";
    };
  };
}
