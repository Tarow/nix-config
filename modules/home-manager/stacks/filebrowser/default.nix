{
  config,
  lib,
  ...
}: let
  name = "filebrowser";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  externalStorage = config.tarow.stacks.externalStorageBaseDir;
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "docker.io/filebrowser/filebrowser:s6";
      volumes = [
        "${externalStorage}:/srv/hdd"
        "/home/:/srv/home/"
        "${storage}/database:/database"
        "${storage}/config:/config"
      ];
      environment = {
        PUID = config.tarow.stacks.defaultUid;
        PGID = config.tarow.stacks.defaultGid;
      };
      port = 80;
      traefik.name = name;
      homepage = {
        category = "Utilities";
        name = "File Browser";
        settings = {
          description = "Web-based file manager";
          icon = "filebrowser";
        };
      };
    };
  };
}
