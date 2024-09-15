{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.tarow.stacks;
in
{
  imports = (lib.tarow.readSubdirs ./.);

  options.tarow.stacks = {
    storageBaseDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/stacks";
    };
    mediaStorageBaseDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/hdd1/media";
    };
  };
  config.virtualisation = {
    arion.backend = if config.tarow.docker.enable then "docker" else "podman-socket";
    podman.dockerSocket.enable = lib.mkIf (config.virtualisation.arion.backend == "podman-socket") true;
  };
}

