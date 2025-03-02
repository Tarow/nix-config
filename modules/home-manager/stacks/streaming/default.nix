{
  config,
  lib,
  ...
}: let
  stackName = "streaming";

  gluetunName = "gluetun";
  qbittorrentName = "qbittorrent";
  jellyfinName = "jellyfin";
  sonarrName = "sonarr";
  radarrName = "radarr";
  bazarrName = "bazarr";
  prowlarrName = "prowlarr";

  cfg = config.tarow.stacks.${stackName};
  storage = "${config.tarow.stacks.storageBaseDir}/${stackName}";
  mediaStorage = "${config.tarow.stacks.mediaSorageBaseDir}";
in {
  options.tarow.stacks.${stackName}.enable = lib.mkEnableOption stackName;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${gluetunName} = {
        image = "docker.io/qmcgaw/gluetun:latest";
        addCapabilities = ["NET_ADMIN"];
        devices = ["/dev/net/tun:/dev/net/tun"];
        volumes = [
          "${storage}/${gluetunName}:/gluetun"
          "${config.sops.secrets."gluetun/config".path}:/gluetun/auth/config.toml"
        ];
        environmentFile = [config.sops.secrets."gluetun/env".path];
        environment = {
          WIREGUARD_MTU = 1380;
          HTTP_CONTROL_SERVER_LOG = "off";
          VPN_SERVICE_PROVIDER = "airvpn";
          VPN_TYPE = "wireguard";
          TZ = config.tarow.stacks.defaultTz;
          UPDATER_PERIOD = "12h";
          HTTPPROXY = "on";
          HEALTH_VPN_DURATION_INITIAL = "60s";
        };

        stack = stackName;
        port = 8888;
        homepage = {
          category = "Networking";
          name = "Gluetun";
          settings = {
            description = "VPN client with firewall and proxy";
            icon = "gluetun";
          };
        };
      };

      ${qbittorrentName} = {
        image = "docker.io/linuxserver/qbittorrent:latest";
        dependsOn = ["gluetun"];
        network = lib.mkForce ["container:gluetun"];
        volumes = [
          "${storage}/${qbittorrentName}:/config"
          "${mediaStorage}:/media"
        ];
        environment = {
          PUID = config.tarow.stacks.defaultUid;
          PGID = config.tarow.stacks.defaultGid;
          UMASK = "022";
          WEBUI_PORT = 8080;
        };

        stack = stackName;
        port = 8080;
        traefik.name = qbittorrentName;
        homepage = {
          category = "Downloads";
          name = "qBittorrent";
          settings = {
            description = "BitTorrent client with Web UI";
            icon = "qbittorrent";
          };
        };
      };

      ${jellyfinName} = {
        image = "lscr.io/linuxserver/jellyfin:latest";
        volumes = [
          "${storage}/${jellyfinName}/config:/config"
          "${mediaStorage}:/media"
        ];
        devices = ["/dev/dri:/dev/dri"];
        environment = {
          PUID = config.tarow.stacks.defaultUid;
          PGID = config.tarow.stacks.defaultGid;
          TZ = config.tarow.stacks.defaultTz;
          JELLYFIN_PublishedServerUrl = config.services.podman.containers.${jellyfinName}.traefik.serviceDomain;
        };

        port = 8096;
        traefik.name = jellyfinName;
        homepage = {
          category = "Media";
          name = "Jellyfin";
          settings = {
            description = "Self-hosted media server";
            icon = "jellyfin";
          };
        };
      };
    };
  };
}
