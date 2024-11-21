{ lib, pkgs, config, ... }:
let
  cfg = config.tarow.gnome;

in
{
  options.tarow.gnome = {
    enable = lib.options.mkEnableOption "Gnome";
  };
  config = lib.mkIf cfg.enable {
    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        show-all-sources = true;
        sources = [
          [ "xkb" "eu" ]
        ];
      };
    };
  };
}
