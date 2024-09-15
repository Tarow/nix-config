{ pkgs, lib, config, inputs, ... }:
let
  name = "audiobookshelf";
  cfg = config.tarow.stacks.${name};
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  mediaStorage = "${config.tarow.stacks.mediaStorageBaseDir}";

  stack = {
    networks.${config.tarow.stacks.traefik.network}.external = lib.mkIf cfg.addToTraefik true;
    services.${name}.service = lib.mkMerge [
      {
        image = "ghcr.io/advplyr/audiobookshelf:latest";
        container_name = name;
        restart = "unless-stopped";
        volumes = [
          "${mediaStorage}/audiobooks:/audiobooks"
          "${storage}/podcasts:/podcasts"
          "${storage}/metadata:/metadata"
          "${storage}/metadata:/config"
        ];
        ports = lib.mkIf (!cfg.addToTraefik) [
          "80:80"
        ];
      }
      (lib.mkIf cfg.addToTraefik {
        labels = (import ../traefik/labels.nix { inherit name config lib; port = 80; }) // (import ../traefik/middlewares.nix name [ "public" ]);
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
