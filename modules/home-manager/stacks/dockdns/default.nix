{
  config,
  lib,
  ...
}: let
  name = "dockdns";
  cfg = config.tarow.stacks.${name};
in {
  imports = [./extension.nix];

  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    sops.templates."dockdns_config.yaml".content = import ./config.nix config;

    services.podman.containers.${name} = {
      image = "ghcr.io/tarow/dockdns:latest";
      volumes = [
        "${config.sops.templates."dockdns_config.yaml".path}:/app/config.yaml"
        "${config.tarow.podman.socketLocation}:/var/run/docker.sock:ro"
      ];

      port = 8080;
      traefik.name = name;
      homepage = {
        category = "Utilities";
        name = "dockdns";
        settings = {
          description = "DNS Updater";
          icon = "azure-dns";
        };
      };
    };
  };
}
