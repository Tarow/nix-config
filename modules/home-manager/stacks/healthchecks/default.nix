{
  config,
  lib,
  ...
}: let
  name = "healthchecks";

  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "lscr.io/linuxserver/healthchecks:latest";
        volumes = ["${storage}/config:/config"];
        environment = {
          PUID = config.tarow.stacks.defaultUid;
          PGID = config.tarow.stacks.defaultGid;
          TZ = config.tarow.stacks.defaultTz;
          SITE_ROOT = config.services.podman.containers.${name}.traefik.serviceDomain;
          SITE_NAME = "Healthchecks";
          REGISTRATION_OPEN = "False";
          INTEGRATIONS_ALLOW_PRIVATE_IPS = "True";
          APPRISE_ENABLED = "True";
          SUPERUSER_EMAIL = "admin@${config.tarow.stacks.traefik.domain}";
        };
        environmentFile = [config.sops.secrets."healthchecks/env".path];
        port = 8000;

        stack = name;
        traefik.name = name;
        homepage = {
          category = "Monitoring";
          name = "Healthchecks";
          settings = {
            description = "Cron job monitoring";
            icon = "healthchecks";
          };
        };
      };
    };
  };
}
