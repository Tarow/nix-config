{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.stacks;
in {
  imports = lib.tarow.readSubdirs ./.;

  options.tarow.stacks = {
    enable = lib.mkEnableOption "Stacks";
    storageBaseDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/niklas/.stacks";
    };
    mediaStorageBaseDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/hdd1/media";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [podman];
  };
}
