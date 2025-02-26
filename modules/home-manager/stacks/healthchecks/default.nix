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
    services.podman.networks.${name} = {};
    services.podman.containers = {
      ${name} = {
        image = "docker.io/healthchecks/healthchecks:latest";
        dependsOn = [dbName];
        exec = "bash -c 'while !</dev/tcp/${dbName}/5432; do sleep 1; done; uwsgi /opt/healthchecks/docker/uwsgi.ini'";
        volumes = ["${storage}/data:/data"];
        environment = {
          inherit DB DB_HOST DB_NAME;
          ALLOWED_HOSTS = "healthchecks.${config.tarow.stacks.traefik.domain}";
          DEBUG = "False";
          SITE_ROOT = "https://healthchecks.${config.tarow.stacks.traefik.domain}";
          REGISTRATION_OPEN = "False";
          SITE_NAME = "Healthchecks";
          INTEGRATIONS_ALLOW_PRIVATE_IPS = "True";
          APPRISE_ENABLED = "True";
        };
        environmentFile = [config.sops.secrets."healthchecks/env".path];
        network = [name];
        port = 8000;
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
        network = [name];
      };
    };
  };
}
