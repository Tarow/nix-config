{
  config,
  lib,
  ...
}: let
  name = "calibre";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "lscr.io/linuxserver/calibre-web";
      volumes = [
        "${storage}/config:/config"
        "${storage}/books:/books"
      ];
      environment = {
        PUID = config.tarow.stacks.defaultUid;
        PGID = config.tarow.stacks.defaultGid;
        TZ = config.tarow.stacks.defaultTz;
        OAUTHLIB_RELAX_TOKEN_SCOPE = 1;
      };
      port = 8083;
      traefik.name = name;
      homepage = {
        category = "General";
        name = "Calibre";
        settings = {
          description = "Ebook Library";
          icon = "calibre-web";
        };
      };
    };
  };
}
