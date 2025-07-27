{
  config,
  lib,
  ...
}: let
  name = "skatcounter";
  cfg = config.tarow.podman.stacks.${name};
  storage = "${config.tarow.podman.storageBaseDir}/${name}";
in {
  options.tarow.podman.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/tarow/skat-counter:main";
      volumes = [
        "${storage}/data:/app"
      ];

      port = 8080;
      traefik.name = "skat";
      traefik.middlewares = ["public"];
    };
  };
}
