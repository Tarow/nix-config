{
  config,
  lib,
  ...
}: let
  name = "stirling-pdf";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "docker.io/frooodle/s-pdf:latest";
      environment = {
        DOCKER_ENABLE_SECURITY = "false";
      };

      port = 8080;
      traefik.name = "pdf";
      homepage = {
        category = "Utilities";
        name = "Stirling PDF";
        settings = {
          description = "Online PDF tools";
          icon = "stirling-pdf";
        };
      };
    };
  };
}
