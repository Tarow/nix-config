{ lib, pkgs, config, ... }:
let
  cfg = config.tarow.java;

in
{
  options.tarow.java = {
    enable = lib.options.mkEnableOption "Java";
  };
  config = lib.mkIf cfg.enable {
    programs.java.enable = true;
  };
}
