{
  config,
  lib,
  ...
}: let
  name = "adguard";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "docker.io/adguard/adguardhome:latest";
      volumes = [
        "${storage}/work:/opt/adguardhome/work"
        "${storage}/conf:/opt/adguardhome/conf"
      ];
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "853:853/tcp"
      ];
      port = 3000;
      traefik.name = name;
      homepage = {
        category = "Network & Administration";
        name = "AdGuard Home";
        settings = {
          description = "Adblocker";
          href = "https://${name}.${config.tarow.stacks.traefik.domain}";
          icon = "adguard-home";
        };
      };
    };
  };
}
