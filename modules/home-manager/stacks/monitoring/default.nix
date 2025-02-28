{
  config,
  lib,
  pkgs,
  ...
}: let
  name = "monitoring";
  cfg = config.tarow.stacks.${name};

  grafanaName = "grafana";
  lokiName = "loki";
  promtailName = "promtail";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";

  lokiPort = 3100;
  lokiUrl = "http://${lokiName}:${toString lokiPort}";
  grafanaDatasources = pkgs.writeText "datasources.yaml" (import ./grafana_datasources.nix lokiUrl);
  lokiConfig = pkgs.writeText "config-local.yaml" (import ./loki_local_config.nix lokiPort);
  promtailConfig = pkgs.writeText "config.yaml" (import ./promtail_config.nix lokiUrl);
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${grafanaName} = {
        image = "grafana/grafana:latest";
        user = config.tarow.stacks.defaultUid;
        volumes = [
          "${grafanaDatasources}:/etc/grafana/provisioning/datasources/datasources.yaml"
          "${storage}/grafana/data:/var/lib/grafana"
        ];
        environment = {
          GF_AUTH_ANONYMOUS_ENABLED = "true";
          GF_AUTH_ANONYMOUS_ORG_ROLE = "Admin";
          GF_AUTH_DISABLE_LOGIN_FORM = "true";
        };

        port = 3000;
        stack = name;
        traefik.name = name;
        homepage = {
          category = "Monitoring";
          name = "Grafana";
          settings = {
            description = "Open-source platform for monitoring and observability";
            icon = "grafana";
          };
        };
      };

      ${lokiName} = {
        image = "grafana/loki:latest";
        exec = "-config.file=/etc/loki/local-config.yaml";
        user = config.tarow.stacks.defaultUid;
        volumes = [
          "${storage}/loki/data:/loki"
          "${lokiConfig}:/etc/loki/local-config.yaml"
        ];
        stack = name;
        homepage = {
          category = "Monitoring";
          name = "Loki";
          settings = {
            description = "Open-source log aggregation system";
            icon = "loki";
          };
        };
      };

      ${promtailName} = {
        image = "grafana/promtail:latest";
        volumes = [
          "${promtailConfig}:/etc/promtail/config.yaml"
          "${config.tarow.podman.socketLocation}:/var/run/docker.sock:ro"
        ];
        exec = "-config.file=/etc/promtail/config.yaml";
        dependsOn = [lokiName];
        stack = name;
        homepage = {
          category = "Monitoring";
          name = "Promtail";
          settings = {
            description = "Log collection agent for Loki";
            icon = "loki";
          };
        };
      };
    };
  };
}
