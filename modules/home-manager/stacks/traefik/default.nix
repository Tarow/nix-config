{
  lib,
  config,
  pkgs,
  ...
}: let
  name = "traefik";
  cfg = config.tarow.stacks.${name};

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
      description = "Network for the Traefik docker provider";
      default = "traefik-proxy";
    };
  };

  config = lib.mkIf cfg.enable {
    services.podman.networks.${cfg.network} = {
      driver = "bridge";
      extraPodmanArgs = [
      ];
    };

    services.podman.containers.${name} = {
      image = "traefik:v3";
      ports = [
        "443:443"
        "80:80"
      ];
      environmentFile = [config.sops.secrets."traefik/env".path];
      volumes = [
        "${storage}/letsencrypt:/letsencrypt"
        "/run/user/1000/podman/podman.sock:/var/run/docker.sock:ro"
        "${pkgs.writeText "traefik.yml" (import ./config/traefik.nix {inherit (cfg) domain;})}:/etc/traefik/traefik.yml:ro"
        "${./config/dynamic.yml}:/dynamic/config.yml"
        "${storage}/plugins:/plugins"
      ];
      labels = {
        "logging.promtail" = "true";
        "traefik.enable" = "true";
        "traefik.http.routers.api.entrypoints" = "websecure";
        "traefik.http.routers.api.rule" = ''Host(\`${name}.${cfg.domain}\`)'';
        "traefik.http.routers.api.middlewares" = "private-chain@file";
        "traefik.http.routers.api.service" = "api@internal";
      };
      network = [cfg.network];
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
