{
  pkgs,
  config,
  lib,
  ...
}: let
  stackName = "pangolin";
  pangolinName = "pangolin";
  traefikName = "traefik";

  cfg = config.tarow.stacks.${stackName};
  storage = "${config.tarow.stacks.storageBaseDir}/${stackName}";

  traefikConfig = pkgs.writeText "traefik_config.yml" (import ./traefik/traefik_config.nix cfg.domain);
  traefikDynamicConfig = pkgs.writeText "dynamic_config.yml" (import ./traefik/dynamic_config.nix cfg.domain);
in {
  options.tarow.stacks.${stackName} = {
    enable = lib.mkEnableOption stackName;
    domain = lib.options.mkOption {
      type = lib.types.str;
      description = "Base domain handled by Pangolin";
    };
  };
  config = lib.mkIf cfg.enable {
    sops.templates."pangolin_config.yml".content = import ./config.nix config cfg.domain;

    services.podman.containers = {
      ${pangolinName} = {
        image = "fosrl/pangolin:1.0.1";

        volumes = [
          "${storage}/config:/app/config"
          "${config.sops.templates."pangolin_config.yml".path}:/app/config/config.yml"
          "${traefikConfig}:/app/config/traefik/traefik_config.yml"
          "${traefikDynamicConfig}:/app/config/traefik/dynamic_config.yml"
        ];
        extraConfig.Container = {
          HealthCmd = "curl -f http://localhost:3001/api/v1/";
          HealthInterval = "3s";
          HealthTimeout = "3s";
          HealthRetries = 5;
        };
        stack = stackName;
      };

      ${traefikName} = {
        image = "traefik:v3.3.3";
        ports = [
          "443:443"
          "80:80"
        ];
        dependsOn = [pangolinName];
        volumes = [
          "${storage}/config/letsencrypt:/letsencrypt"
          "${traefikConfig}:/etc/traefik/traefik_config.yml"
          "${traefikDynamicConfig}:/etc/traefik/dynamic_config.yml"
        ];
        environmentFile = [config.sops.secrets."traefik/env".path];
        exec = "--configFile=/etc/traefik/traefik_config.yml";
        stack = stackName;
      };
    };
  };
}
