{
  lib,
  config,
  ...
}: let
  name = "homepage";
  cfg = config.tarow.stacks.${name};
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  mediaStorage = "${config.tarow.stacks.mediaStorageBaseDir}";
  port = 3000;

  stack = {
    networks.${config.tarow.stacks.traefik.network}.external = lib.mkIf cfg.addToTraefik true;
    services.${name}.service = lib.mkMerge [
      {
        image = "ghcr.io/gethomepage/homepage:latest";
        container_name = name;
        restart = "unless-stopped";
        volumes = [
          "${storage}/config:/app/config"
          "${mediaStorage}:/mnt/hdd1:ro"
          "${storage}/icons:/app/public/icons"
          "${storage}/images:/app/public/images"
          "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];
        environment = {
          PUID = toString config.tarow.stacks.uid;
          PGID = toString config.tarow.stacks.gid;
          LOG_LEVEL = "debug";
        };
        ports = lib.mkIf (!cfg.addToTraefik) [
          "${toString port}:${toString port}"
        ];
      }
      (lib.mkIf cfg.addToTraefik {
        labels = import ../traefik/labels.nix {
          inherit name config lib;
          port = port;
        };
        networks = [config.tarow.stacks.traefik.network];
      })
    ];
  };
in {
  options.tarow.stacks.${name} = with lib; {
    enable = options.mkEnableOption name;
    addToTraefik = options.mkOption {
      type = types.bool;
      default = config.tarow.stacks.traefik.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.arion.projects.${name}.settings = stack;
  };
}
