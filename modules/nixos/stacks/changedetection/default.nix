{ pkgs, lib, config, inputs, ... }:
let
  name = "changedetection";
  port = 5000;
  cfg = config.tarow.stacks.${name};
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  mediaStorage = "${config.tarow.stacks.mediaStorageBaseDir}";

  playwrightContainer = "playwright-chrome";

  stack = {
    networks.${config.tarow.stacks.traefik.network}.external = lib.mkIf cfg.addToTraefik true;
    services.${name}.service = lib.mkMerge [
      {
        image = "dgtlmoon/changedetection.io:latest";
        container_name = name;
        restart = "unless-stopped";
        volumes = [
          "${storage}/data:/config"
        ];
        environment = {
          PUID = 1000;
          PGID = 1000;
          PLAYWRIGHT_DRIVER_URL = "ws://${playwrightContainer}:3000/?stealth=1&--disable-web-security=true";
          FETCH_WORKERS = "1";
        };
        ports = lib.mkIf (!cfg.addToTraefik) [
          "${toString port}:${toString port}"
        ];
        networks = [ "default" ];
      }
      (lib.mkIf cfg.addToTraefik {
        labels = (import ../traefik/labels.nix {
          inherit name config lib port;
        }) // (import ../traefik/middlewares.nix name [ "private" ]);
        networks = [ config.tarow.stacks.traefik.network ];
      })
    ];
    services.${playwrightContainer}.service = {
      container_name = playwrightContainer;
      image = "browserless/chrome:latest";
      restart = "unless-stopped";
    };
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
