name:
{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.tarow.stacks.${name};
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  mediaStorage = "${config.tarow.stacks.mediaStorageBaseDir}";

  stack = {
    networks.${config.tarow.stacks.traefik.network}.external = lib.mkIf cfg.addToTraefik true;
    services.${name}.service = lib.mkMerge [
      {
        image = "lscr.io/linuxserver/readarr:develop";
        container_name = name;
        restart = "unless-stopped";
        environment = {
          PUID = 1000;
          PGID = 1000;
          TZ = "Europe/Berlin";
        };
        volumes = [
          "${storage}/config:/config"
          "${mediaStorage}:/media"
        ];
        ports = lib.lists.optional (!cfg.addToTraefik) "8787:8787";
      }
      (lib.mkIf cfg.addToTraefik {
        labels = (import ../traefik/labels.nix { inherit name config lib; port = 8787; }) // (import ../traefik/middlewares.nix name [ "private" ]);
        networks = [ config.tarow.stacks.traefik.network ];
      })
    ];
  };
in
{
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
