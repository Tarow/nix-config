{
  lib,
  config,
  pkgs,
  ...
}: let
  name = "traefik";
  cfg = config.tarow.stacks.${name};

  yaml = pkgs.formats.yaml {};

  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
in {
  imports = [
    ./extension.nix
  ];

  options.tarow.stacks.${name} = {
    enable = lib.options.mkEnableOption name;
    domain = lib.options.mkOption {
      type = lib.types.str;
      description = "Base domain handled by Traefik";
    };
    network = lib.options.mkOption {
      type = lib.types.str;
      description = "Network name of the Traefik docker provider";
      default = "traefik-proxy";
    };
    staticConfig = lib.options.mkOption {
      type = yaml.type;
      default = import ./config/traefik.nix cfg.domain cfg.network;
      apply = yaml.generate "traefik.yml";
    };
    dynamicConfig = lib.options.mkOption {
      type = yaml.type;
      default = import ./config/dynamic.nix;
      apply = yaml.generate "dynamic.yml";
    };
  };

  config = lib.mkIf cfg.enable {
    services.podman.networks.${cfg.network} = {
      driver = "bridge";
      extraPodmanArgs = [
      ];
    };

    services.podman.containers.${name} = {
      image = "docker.io/traefik:v3";

      socketActivation = [
        {
          port = 80;
          fileDescriptorName = "web";
        }
        {
          port = 443;
          fileDescriptorName = "websecure";
        }
      ];
      ports = [
        #"443:443"
        #"80:80"
      ];
      environmentFile = [config.sops.secrets."traefik/env".path];
      volumes = [
        "${storage}/letsencrypt:/letsencrypt"
        "${config.tarow.podman.socketLocation}:/var/run/docker.sock:ro"
        "${cfg.staticConfig}:/etc/traefik/traefik.yml:ro"
        "${cfg.dynamicConfig}:/dynamic/config.yml"
        "${./config/IP2LOCATION-LITE-DB1.IPV6.BIN}:/plugins/geoblock/IP2LOCATION-LITE-DB1.IPV6.BIN"
      ];
      labels = lib.mkForce {
        "traefik.enable" = "true";
        "traefik.http.routers.api.entrypoints" = "websecure";
        "traefik.http.routers.api.rule" = ''Host(\`${name}.${cfg.domain}\`)'';
        "traefik.http.routers.api.middlewares" = "private-chain@file";
        "traefik.http.routers.api.service" = "api@internal";
        "logging.alloy" = "true";
      };
      network = [cfg.network];

      alloy.enable = true;
      homepage = {
        category = "General";
        name = "Traefik";
        settings = {
          description = "Reverse Proxy";
          href = "https://${name}.${cfg.domain}";
          icon = "traefik";
        };
      };
    };
  };
}
