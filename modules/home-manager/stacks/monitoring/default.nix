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
  prometheusName = "prometheus";
  alloyName = "alloy";
  storage = "${config.tarow.stacks.storageBaseDir}/${stackName}";

  lokiPort = 3100;
  lokiUrl = "http://${lokiName}:${toString lokiPort}";

  prometheusPort = 9090;
  prometheusUrl = "http://${prometheusName}:${toString prometheusPort}";

  lokiConfig = pkgs.writeText "config-local.yaml" (import ./loki_local_config.nix lokiPort);
  alloyConfig = pkgs.writeText "config.alloy" (import ./alloy_config.nix lokiUrl);
in {
  imports = [./extension.nix];

  options.tarow.stacks.${stackName}.enable = lib.mkEnableOption stackName;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${grafanaName} = let
        grafanaDatasources = pkgs.writeText "datasources.yaml" (import ./grafana_datasources.nix lokiUrl prometheusUrl);
        dashboardPath = "/var/lib/grafana/dashboards";
        dashboardProvider = pkgs.writeText "provider.yml" ''
          apiVersion: 1
          providers:
            - name: "Dashboard provider"
              orgId: 1
              type: file
              disableDeletion: false
              updateIntervalSeconds: 10
              allowUiUpdates: false
              options:
                path: ${dashboardPath}
                foldersFromFilesStructure: true
        '';
      in {
        image = "docker.io/grafana/grafana:latest";
        user = config.tarow.stacks.defaultUid;
        volumes = [
          "${storage}/grafana/data:/var/lib/grafana"
          "${grafanaDatasources}:/etc/grafana/provisioning/datasources/datasources.yaml"
          "${dashboardProvider}:/etc/grafana/provisioning/dashboards/provider.yml"
        ] ++ (builtins.readDir ./dashboards |> builtins.attrNames |> map (file: "${./dashboards}/${file}:${dashboardPath}/${file}"));

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
        image = "docker.io/grafana/loki:latest";
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
        image = "docker.io/grafana/alloy:latest";
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

      ${prometheusName} = let
        configDst = "/etc/prometheus/prometheus.yml";
      in {
        image = "docker.io/prom/prometheus:latest";
        exec = "--config.file=${configDst}";
        user = config.tarow.stacks.defaultUid;
        volumes = [
          "${storage}/prometheus/data:/prometheus"
          "${./prometheus_config.yml}:${configDst}"
        ];

        port = prometheusPort;
        stack = stackName;
        traefik.name = "prometheus";
        homepage = {
          category = "Monitoring";
          name = "Prometheus";
          settings = {
            description = "Open-source monitoring system";
            icon = "prometheus";
          };
        };
      };

      pod-exporter = {
        image = "quay.io/navidys/prometheus-podman-exporter:latest";
        volumes = [
          "${config.tarow.podman.socketLocation}:/var/run/podman/podman.sock"
        ];
        environment.CONTAINER_HOST = "unix:///var/run/podman/podman.sock";
        user = config.tarow.stacks.defaultUid;
        extraPodmanArgs = ["--security-opt=label=disable"];

        stack = stackName;
      };
    };
  };
}
