{
  config,
  lib,
  ...
}: let
  name = "crowdsec";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "docker.io/crowdsecurity/crowdsec:latest";
      volumes = [
        "${storage}/db:/var/lib/crowdsec/data"
        "${storage}/config:/etc/crowdsec"
        "${./acquis.yaml}:/etc/crowdsec/acquis.yaml"
        "${config.tarow.podman.socketLocation}:/var/run/docker.sock:ro"
      ];
      environment = {
        COLLECTIONS = "crowdsecurity/traefik crowdsecurity/http-cve crowdsecurity/whitelist-good-actors";
        UID = config.tarow.stacks.defaultUid;
        GID = config.tarow.stacks.defaultGid;
      };
      environmentFile = [config.sops.secrets."crowdsec/env".path];
      network = lib.optional config.tarow.stacks.traefik.enable config.tarow.stacks.traefik.network;

      homepage = {
        category = "Network & Administration";
        name = "Crowdsec";
        settings = {
          description = "Adblocker";
          icon = "crowdsec";
        };
      };
    };
  };
}
