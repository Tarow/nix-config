{
  config,
  lib,
  ...
}: let
  name = "uptime-kuma";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/louislam/uptime-kuma:beta";
      volumes = [
        "${storage}/data:/app/data"
        "${config.tarow.podman.socketLocation}:/var/run/docker.sock:ro"
      ];
      environment = {
        UPTIME_KUMA_DB_TYPE = "sqlite";
        PUID = config.tarow.stacks.defaultUid;
        PGID = config.tarow.stacks.defaultGid;
      };

      port = 3001;
      traefik = {
        inherit name;
        subDomain = "uptime";
      };
      homepage = {
        category = "Network & Administration";
        name = "Uptime Kuma";
        settings = {
          description = "Uptime Monitoring";
          icon = "uptime-kuma";
        };
      };
    };
  };
}
