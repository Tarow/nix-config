{
  config,
  lib,
  pkgs,
  ...
}: let
  stackName = "monitoring";
  cfg = config.tarow.stacks.${stackName};

  grafanaName = "grafana";
  lokiName = "loki";
  alloyName = "alloy";
  storage = "${config.tarow.stacks.storageBaseDir}/${stackName}";

  lokiPort = 3100;
  lokiUrl = "http://${lokiName}:${toString lokiPort}";
  grafanaDatasources = pkgs.writeText "datasources.yaml" (import ./grafana_datasources.nix lokiUrl);
  lokiConfig = pkgs.writeText "config-local.yaml" (import ./loki_local_config.nix lokiPort);
  alloyConfig = pkgs.writeText "config.alloy" (import ./alloy_config.nix lokiUrl);
in {
  imports = [./extension.nix];

  options.tarow.stacks.${stackName}.enable = lib.mkEnableOption stackName;

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
        stack = stackName;
        traefik.name = grafanaName;
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

        stack = stackName;
        homepage = {
          category = "Monitoring";
          name = "Loki";
          settings = {
            description = "Open-source log aggregation system";
            icon = "loki";
          };
        };
      };

      ${alloyName} = let
        port = 12345;
        configDst = "/etc/alloy/config.alloy";
      in {
        image = "grafana/alloy:latest";
        volumes = [
          "${alloyConfig}:${configDst}"
          "${config.tarow.podman.socketLocation}:/var/run/docker.sock:ro"
        ];
        exec = "run --server.http.listen-addr=0.0.0.0:${toString port} --storage.path=/var/lib/alloy/data ${configDst}";

        stack = stackName;
        inherit port;
        traefik.name = alloyName;
        homepage = {
          category = "Monitoring";
          name = "Alloy";
          settings = {
            description = "Open-source observability pipeline";
            icon = "alloy";
          };
        };
      };
    };
  };
}
