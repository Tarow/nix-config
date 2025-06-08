{
  config,
  lib,
  ...
}: let
  name = "immich";

  dbName = "${name}-db";
  redisName = "${name}-redis";
  mlName = "${name}-machine-learning";

  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  mediaStorage = "${config.tarow.stacks.mediaStorageBaseDir}";
  cfg = config.tarow.stacks.${name};

  env = {
    TZ = config.tarow.stacks.defaultTz;
    DB_HOSTNAME = dbName;
    DB_USERNAME = "postgres";
    DB_DATABASE_NAME = "immich";
    REDIS_HOSTNAME = redisName;
    NODE_ENV = "production";
    UPLOAD_LOCATION = "/usr/src/app/upload";
    IMMICH_CONFIG_FILE = "/usr/src/app/config/config.json";
  };
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "ghcr.io/immich-app/immich-server:release";
        volumes = [
          "${./config.json}:${env.IMMICH_CONFIG_FILE}"
          "${mediaStorage}/pictures/immich:${env.UPLOAD_LOCATION}"
        ];

        environment = env;
        environmentFile = [config.sops.secrets."immich/env".path];
        devices = ["/dev/dri:/dev/dri"];

        dependsOn = [redisName dbName];
        port = 2283;

        stack = name;
        traefik = {
          name = name;
          middlewares = ["public"];
        };
        homepage = {
          category = "Media";
          name = "Immich";
          settings = {
            description = "Self-hosted photo and video management";
            icon = "immich";
          };
        };
      };

      ${redisName} = {
        image = "docker.io/redis:6.2";
        stack = name;
      };

      ${dbName} = {
        image = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0";
        volumes = ["${storage}/pgdata:/var/lib/postgresql/data"];

        environmentFile = [config.sops.secrets."immich/db_env".path];
        environment = {
          POSTGRES_USER = env.DB_USERNAME;
          POSTGRES_DB = env.DB_DATABASE_NAME;
        };

        stack = name;
      };

      ${mlName} = {
        image = "ghcr.io/immich-app/immich-machine-learning:release";
        volumes = ["${storage}/model-cache:/cache"];

        stack = name;
      };
    };
  };
}
