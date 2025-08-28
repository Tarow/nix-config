{
  config,
  lib,
  ...
}: let
  name = "skatcounter";
  cfg = config.nps.stacks.${name};
  storage = "${config.nps.storageBaseDir}/${name}";
in {
  options.nps.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/tarow/skat-counter:main";
      volumes = [
        "${storage}/data:/app"
      ];

      port = 8080;
      traefik.name = "skat";
      traefik.middleware.public.enable = true;
    };
  };
}
