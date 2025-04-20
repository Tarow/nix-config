{
  config,
  lib,
  ...
}: let
  name = "skatcounter";
  cfg = config.tarow.stacks.${name};
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/tarow/skat-counter:main";
      volumes = [
        "${storage}/data:/app"
      ];

      port = 8080;
      traefik.name = "skat";
    };
  };
}
