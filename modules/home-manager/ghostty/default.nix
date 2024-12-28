{ lib, pkgs, config, inputs, ... }:
let
  cfg = config.tarow.ghostty;
in
{
  options.tarow.ghostty = {
    enable = lib.options.mkEnableOption "Ghostty";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ inputs.ghostty.packages.x86_64-linux.default ];
  };
}
