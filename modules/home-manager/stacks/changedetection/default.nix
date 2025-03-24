{
  config,
  lib,
  ...
}: let
  name = "changedetection";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "ghcr.io/dgtlmoon/changedetection.io";
        volumes = [
          "${storage}:/datastore"
        ];
        environment = {
          PLAYWRIGHT_DRIVER_URL = "ws://sockpuppetbrowser:3000";
        };

        stack = name;
        port = 5000;
        traefik.name = name;
        homepage = {
          category = "Utilities";
          name = "Changedetection";
          settings = {
            description = "Website Change Detection";
            icon = "changedetection";
          };
        };
      };

      sockpuppetbrowser = {
        image = "dgtlmoon/sockpuppetbrowser:latest";
        environment = {
          SCREEN_WIDTH = 1920;
          SCREEN_HEIGHT = 1024;
          SCREEN_DEPTH = 16;
          MAX_CONCURRENT_CHROME_PROCESSES = 10;
        };
        addCapabilities = ["SYS_ADMIN"];

        stack = name;
      };
    };
  };
}
