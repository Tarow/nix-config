{config, ...}: let
  name = "homepage";
  mediaStorage = config.tarow.stacks.mediaStorageBaseDir;

  container = {
    image = "ghcr.io/gethomepage/homepage:latest";
    volumes = [
      "${mediaStorage}:/mnt/hdd1:ro"
      "${./config/docker.yaml}:/app/config/docker.yaml"
      "${./config/services.yaml}:/app/config/services.yaml"
      "${./config/settings.yaml}:/app/config/settings.yaml"
      "${./config/widgets.yaml}:/app/config/widgets.yaml"

      "/run/user/1000/podman/podman.sock:/var/run/docker.sock:ro"
    ];
    environment = {
      PUID = config.tarow.stacks.defaultUid;
      PGID = config.tarow.stacks.defaultGid;
    };
  };
in {
  imports = [
    (import ../mkContainer.nix {
      inherit name container;
      port = 3000;
    })
  ];
}
