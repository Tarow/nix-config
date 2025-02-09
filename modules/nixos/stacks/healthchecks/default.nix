{
  lib,
  config,
  ...
}: let
  name = "healthchecks";
  cfg = config.tarow.stacks.${name};
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";

  stack = {
    services.${name}.service = {
      image = "healthchecks/healthchecks:latest";
      volumes = [
        "${storage}/data:/data"
      ];
      depends_on = ["postgres"];
      command = "bash -c 'while !</dev/tcp/postgres/5432; do sleep 1; done; uwsgi /opt/healthchecks/docker/uwsgi.ini'";
      networks = ["default"];
      environment =
        (import ./env.nix)
        // lib.optionalAttrs cfg.addToTraefik {
          SITE_ROOT = "https://${name}.${config.tarow.stacks.traefik.domain}";
          ALLOWED_HOSTS = "${name}.${config.tarow.stacks.traefik.domain}";
        };
    };

    services.postgres.service = {
      image = "postgres:16";
      restart = "unless-stopped";
      volumes = [
        "${storage}/db:/var/lib/postgresql/data"
      ];
      environment = {
        POSTGRES_DB = "hc";
        POSTGRES_PASSWORD = "test123";
      };
    };
  };
in {
  imports = [
    (import ../base.nix {
      inherit name;
      port = 8000;
      hostPort = 8081;
    })
  ];

  config = lib.mkIf cfg.enable {
    virtualisation.arion.projects.${name}.settings = stack;
  };
}
