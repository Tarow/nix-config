{
  config,
  lib,
  ...
}: let
  name = "mealie";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "ghcr.io/mealie-recipes/mealie:latest";
        volumes = ["${storage}/data:/app/data/"];
        environment = {
          ALLOW_SIGNUP = false;
          PUID = config.tarow.stacks.defaultUid;
          PGID = config.tarow.stacks.defaultGid;
          TZ = config.tarow.stacks.defaultTz;
          BASE_URL = config.services.podman.containers.${name}.traefik.serviceDomain;
          DB_ENGINE = "sqlite";
        };

        port = 9000;
        traefik.name = name;
        homepage = {
          category = "Utilities";
          name = "Mealie";
          settings = {
            description = "Self-hosted recipe manager";
            icon = "mealie";
          };
        };
      };
    };
  };
}
