{ pkgs, lib, config, inputs, ... }:
let
  name = "calibre-web";
  port = 8083;
  cfg = config.tarow.stacks.${name};
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  mediaStorage = "${config.tarow.stacks.mediaStorageBaseDir}";

  stack = {
    networks.${config.tarow.stacks.traefik.network}.external = lib.mkIf cfg.addToTraefik true;
    services.${name}.service = lib.mkMerge [
      {
        image = "lscr.io/linuxserver/calibre-web:latest";
        container_name = name;
        restart = "unless-stopped";
        volumes = [
          "${storage}/config:/config"
          "${storage}/books:/books"
        ];
        environment = {
          PUID = 1000;
          PGID = 1000;
          TZ = "Europe/Berlin";
          OAUTHLIB_RELAX_TOKEN_SCOPE = "1";
        };
        ports = lib.mkIf (!cfg.addToTraefik) [
          "${toString port}:${toString port}"
        ];
      }
      (lib.mkIf cfg.addToTraefik {
        labels = (import ../traefik/labels.nix { inherit name config lib port; }) // (import ../traefik/middlewares.nix name [ "private" ]);
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
