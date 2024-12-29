{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.tarow.stylix;
in
{
  options.tarow.stylix = {
    enable = lib.options.mkEnableOption "Stylix";
  };

  imports = [ inputs.stylix.homeManagerModules.stylix ];

  config = lib.mkIf cfg.enable {
    stylix.enable = true;
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
  };
}
