{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.tarow.stylix;
in {
  options.tarow.stylix = {
    enable = lib.options.mkEnableOption "Stylix";
  };

  imports = [inputs.stylix.nixosModules.stylix];

  config = lib.mkIf cfg.enable {
    stylix.homeManagerIntegration.autoImport = false;
    stylix = {
      enable = true;
      #image = pkgs.nixos-artwork.wallpapers.simple-dark-gray.gnomeFilePath;
      image = ./wallpaper.png;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";

      polarity = "dark";
      fonts = {
        monospace = {
          package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
          name = "JetBrainsMono Nerd Font Mono";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
      };
    };
  };
}
