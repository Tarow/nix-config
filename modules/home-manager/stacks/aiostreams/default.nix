{
  config,
  lib,
  ...
}: let
  name = "aiostreams";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/viren070/aiostreams:latest";
      volumes = [
        "${storage}/work:/opt/adguardhome/work"
        "${storage}/conf:/opt/adguardhome/conf"
      ];
      extraConfig.Container = {
        HealthCmd = "wget -qO- http://localhost:3000/health";
        HealthInterval = "1m";
        HealthTimeout = "10s";
        HealthRetries = 5;
        HealthStartPeriod = "10s";
      };

      port = 3000;
      traefik.name = name;
      homepage = {
        category = "Media";
        name = "AIOStreams";
        settings = {
          description = "Stream Source Aggregator";
          icon = "stremio";
        };
      };
    };
  };
}
