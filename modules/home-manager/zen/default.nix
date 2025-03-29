{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.zen-browser;
in {
  options.tarow.zen-browser = {
    enable = lib.options.mkEnableOption "zen-browser";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [inputs.zen-browser.packages."${pkgs.system}".twilight];
  };
}
