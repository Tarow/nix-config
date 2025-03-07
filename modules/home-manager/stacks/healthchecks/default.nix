{
  config,
  lib,
  ...
}: let
  name = "healthchecks";
  dbName = "${name}-db";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};

  DB = "postgres";
  DB_HOST = "postgres";
  DB_NAME = "hc";
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "lscr.io/linuxserver/healthchecks:latest";
        dependsOn = [dbName];
        volumes = ["${storage}/data:/data"];
        #environmentFile
        environment = {
          PUID = config.tarow.stacks.defaultUid;
          PGID = config.tarow.stacks.defaultGid;
          TZ = config.tarow.stacks.defaultTz;
          inherit DB DB_HOST DB_NAME;
          DEBUG = "False";
          #ALLOWED_HOSTS = "${name}.${config.tarow.stacks.traefik.domain}";
          SUPERUSER_EMAIL = "admin@${config.tarow.stacks.traefik.domain}";
          SITE_ROOT = "https://${name}.${config.tarow.stacks.traefik.domain}";
          SITE_NAME = "Healthchecks";
          REGISTRATION_OPEN = "False";
          INTEGRATIONS_ALLOW_PRIVATE_IPS = "True";
          APPRISE_ENABLED = "True";
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

      ${dbName} = {
        image = "docker.io/postgres:16";
        volumes = ["${storage}/db:/var/lib/postgresql/data"];
        environment = {
          POSTGRES_DB = DB_NAME;
        };
        environmentFile = [config.sops.secrets."healthchecks/db_env".path];

        stack = name;
      };
    };
  };
}
