{
  config,
  lib,
  pkgs,
  ...
}: let
  stackName = "monitoring";
  cfg = config.tarow.stacks.${stackName};
  storage = "${config.tarow.stacks.storageBaseDir}/${stackName}";

  yaml = pkgs.formats.yaml {};

  grafanaName = "grafana";
  lokiName = "loki";
  prometheusName = "prometheus";
  alloyName = "alloy";

  dashboardPath = "/var/lib/grafana/dashboards";

  lokiUrl = "http://${lokiName}:${toString cfg.loki.port}";
  prometheusUrl = "http://${prometheusName}:${toString cfg.prometheus.port}";
in {
  imports = [./extension.nix];

  options.tarow.stacks.${stackName} = {
    enable = lib.mkEnableOption stackName;
    grafana = {
      dashboardProvider = lib.mkOption {
        type = yaml.type;
        default = import ./dashboard_provider.nix dashboardPath;
        apply = yaml.generate "dashboard_provider.yml";
      };
      dashboards = lib.mkOption {
        type = lib.types.path;
        default = ./dashboards;
      };
      datasources = lib.mkOption {
        type = yaml.type;
        default = import ./grafana_datasources.nix lokiUrl prometheusUrl;
        apply = yaml.generate "grafana_datasources.yml";
      };
    };
    loki = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 3100;
      };
      config = lib.mkOption {
        type = yaml.type;
        default = import ./loki_local_config.nix cfg.loki.port;
        apply = yaml.generate "loki_config.yaml";
      };
    };
    alloy = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 12345;
      };
      config = lib.mkOption {
        type = lib.types.lines;
        default = import ./alloy_config.nix lokiUrl;
        apply = pkgs.writeText "config.alloy";
      };
    };
    prometheus = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 9090;
      };
      config = lib.mkOption {
        type = yaml.type;
        default = import ./prometheus_config.nix;
        apply = yaml.generate "prometheus_config.yml";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${grafanaName} = {
        image = "docker.io/grafana/grafana:latest";
        user = config.tarow.stacks.defaultUid;
        volumes = [
          "${storage}/grafana/data:/var/lib/grafana"
          "${cfg.grafana.datasources}:/etc/grafana/provisioning/datasources/datasources.yaml"
          "${cfg.grafana.dashboardProvider}:/etc/grafana/provisioning/dashboards/provider.yml"
          "${cfg.grafana.dashboards}:${dashboardPath}"
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
        image = "docker.io/grafana/loki:latest";
        exec = "-config.file=/etc/loki/local-config.yaml";
        user = config.tarow.stacks.defaultUid;
        volumes = [
          "${storage}/loki/data:/loki"
          "${cfg.loki.config}:/etc/loki/local-config.yaml"
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
        configDst = "/etc/alloy/config.alloy";
      in {
        image = "docker.io/grafana/alloy:latest";
        volumes = [
          "${cfg.alloy.config}:${configDst}"
          "${config.tarow.podman.socketLocation}:/var/run/docker.sock:ro"
        ];
        exec = "run --server.http.listen-addr=0.0.0.0:${toString cfg.alloy.port} --storage.path=/var/lib/alloy/data ${configDst}";

        stack = stackName;
        inherit (cfg.alloy) port;
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
          "${yaml.generate "prometheus_config.yml" (import ./prometheus_config.nix)}:${configDst}"
        ];

        port = cfg.prometheus.port;
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
