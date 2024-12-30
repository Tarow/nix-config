{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.networkManager;
in {
  options.tarow.networkManager = {
    enable = lib.options.mkEnableOption "NetworkManager";
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
  };
}
