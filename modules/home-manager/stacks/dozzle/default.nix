{
  config,
  lib,
  ...
}: let
  name = "dozzle";
  cfg = config.tarow.stacks.${name};
in {
  imports = [./extension.nix];

  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "docker.io/amir20/dozzle:latest";
      volumes = [
        "${config.tarow.podman.socketLocation}:/var/run/docker.sock:ro"
      ];
      port = 8080;
      traefik.name = name;
      homepage = {
        category = "Monitoring";
        name = "Dozzle";
        settings = {
          description = "Minimal real-time log viewer for containers";
          icon = "dozzle";
        };
      };
    };
  };
}
