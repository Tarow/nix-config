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

    defaultUid = lib.mkOption {
      type = lib.types.int;
      default = 0; # Maps to my own user id when running rootless podman.
    };
    defaultGid = lib.mkOption {
      type = lib.types.int;
      default = 0; # Maps to my own user gid when running rootless podman.
    };
    defaultTz = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Berlin";
    };

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
