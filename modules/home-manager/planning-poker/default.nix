{
  config,
  lib,
  ...
}: let
  name = "planning-poker";

  cfg = config.nps.stacks.${name};
  storage = "${config.nps.storageBaseDir}/${name}";
in {
  options.nps.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers = {
      ${name} = {
        image = "docker.io/axeleroy/self-host-planning-poker";
        volumes = [
          "${storage}/data:/data"
        ];

        port = 8000;

        traefik.name = "poker";
        expose = true;
      };
    };
  };
}
