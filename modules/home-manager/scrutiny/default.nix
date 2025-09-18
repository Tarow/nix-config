{
  config,
  lib,
  ...
}: let
  name = "scrutiny";
  cfg = config.tarow.${name};
in {
  options.tarow.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    nps.stacks = {
      traefik = {
        enable = true;
        dynamicConfig.http = {
          routers.scrutiny = {
            entryPoints = ["websecure" "websecure-internal"];
            service = "scrutiny";
            middlewares = ["private"];
            rule = "Host(`scrutiny.${config.nps.stacks.traefik.domain}`)";
          };
          services.scrutiny = {
            loadBalancer.servers = [{url = "http://host.containers.internal:8080";}];
          };
        };
      };
      homepage.services = {
        "Monitoring" = {
          "Scrutiny" = {
            description = "Disk Monitoring";
            href = "https://scrutiny.${config.nps.stacks.traefik.domain}";
            siteMonitor = "http://host.containers.internal:8080";
            icon = "scrutiny";
            widget = {
              type = "scrutiny";
              url = "http://host.containers.internal:8080";
            };
          };
        };
      };
    };
  };
}
