{
  lib,
  config,
  inputs,
  ...
}: {
  imports = lib.tarow.readSubdirs ./. ++ [inputs.arion.nixosModules.arion];

  options.tarow.stacks = {
    uid = lib.mkOption {
      type = lib.types.int;
      default = 1000;
    };
    gid = lib.mkOption {
      type = lib.types.int;
      default = 100;
    };

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
    arion.backend =
      if config.tarow.docker.enable
      then "docker"
      else "podman-socket";
    podman.dockerSocket.enable = lib.mkIf (config.virtualisation.arion.backend == "podman-socket") true;
  };
}
