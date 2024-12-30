{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.displaylink;

  displaylinkOverlay = final: prev: {
    displaylink = prev.displaylink.overrideAttrs (old: {
      version = "6.1.0-17";
      src = ./displaylink-610.zip;
    });
  };
in {
  options.tarow.displaylink = {
    enable = lib.options.mkEnableOption "DisplayLink";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [displaylinkOverlay];
    services.xserver.videoDrivers = ["displaylink" "modesetting"];
  };
}
