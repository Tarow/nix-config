{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.podman;
in {
  options.tarow.podman = {
    enable = lib.options.mkEnableOption "Podman";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
