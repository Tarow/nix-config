{
  config,
  lib,
  ...
}: let
  name = "wg-easy";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/wg-easy/wg-easy:latest";
      volumes = [
        "${storage}/config:/etc/wireguard"
      ];

      ports = ["51820:51820/udp"];
      addCapabilities = ["NET_ADMIN" "NET_RAW" "SYS_MODULE"];
      extraPodmanArgs = [
        "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
        "--sysctl=net.ipv4.ip_forward=1"
      ];
      environmentFile = [config.sops.secrets."wg-easy/env".path];
      environment = {
        WG_HOST = "vpn.${config.tarow.stacks.traefik.domain}";
        WG_DEFAULT_DNS = "1.1.1.1";
        WG_DEFAULT_ADDRESS = "172.20.0.x";
      };

      port = 51821;
      traefik = {
        name = name;
        subDomain = "wg";
      };
      homepage = {
        category = "General";
        name = "Wireguard";
        settings = {
          description = "VPN Server";
          icon = "wireguard";
        };
      };
    };
  };
}
