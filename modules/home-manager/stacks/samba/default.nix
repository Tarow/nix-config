{
  config,
  lib,
  ...
}: let
  name = "samba";
  mediaStorage = "${config.tarow.stacks.mediaStorageBaseDir}/${name}/shares";

  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/servercontainers/samba:smbd-only-latest";
      addCapabilities = ["CAP_NET_ADMIN"];
      volumes = [
        "${mediaStorage}/niklas:/shares/niklas"
        "${mediaStorage}/public:/shares/public"
        "${mediaStorage}/selma:/shares/selma"
      ];
      port = 445;

      environmentFile = [config.sops.secrets."samba/env".path];
      environment = {
        UID_niklas = 1000; #TODO: Fix uid mapping

        SAMBA_CONF_LOG_LEVEL = 3;
        SAMBA_VOLUME_CONFIG_public = ''\"[Public]; path=/shares/public; guest ok = yes; read only = no; browseable = yes\"'';
        SAMBA_VOLUME_CONFIG_niklas = ''\"[Niklas]; path=/shares/niklas; valid users = niklas; guest ok = no; read only = n o; browseable = yes\"'';
        SAMBA_VOLUME_CONFIG_selma = ''\"[Selma]; path=/shares/selma; guest ok = yes; read only = no; browseable = yes\"'';
      };
    };
  };
}
