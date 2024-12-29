{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.tarow.displaylink;

  displaylinkOverlay = final: prev: {
    displaylink = prev.displaylink.overrideAttrs (old: {
      src = ./displaylink-600.zip;
    });
  };
in
{
  options.tarow.displaylink = {
    enable = lib.options.mkEnableOption "DisplayLink";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ displaylinkOverlay ];
    services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
  };
}
