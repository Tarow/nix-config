# Doesn't work in rootless mode, since smartctl needs root to read metadata from devices
{
  config,
  lib,
  ...
}: let
  name = "scrutiny";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name} = with lib; {
    enable = mkEnableOption name;
    devices = mkOption {
      type = types.listOf types.str;
    };
    default = [];
  };

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/analogj/scrutiny:master-omnibus";
      addCapabilities = ["SYS_RAWIO"];
      volumes = [
        "/run/udev:/run/udev:ro"
        "${storage}/config:/opt/scrutiny/config"
        "${storage}/influxdb:/opt/scrutiny/influxdb"
      ];
      inherit (cfg) devices;

      port = 8080;
      traefik.name = name;
      homepage = {
        category = "Monitoring";
        name = "Scrutiny";
        settings = {
          description = "SMART monitoring for disks";
          icon = "scrutiny";
        };
      };
    };
  };
}
