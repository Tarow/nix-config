{
  lib,
  config,
  ...
}: let
  name = "traefik";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name} = {
    enable = lib.options.mkEnableOption name;
    domain = lib.options.mkOption {
      type = lib.types.str;
      description = "Base domain handled by Traefik";
    };
    network = lib.options.mkOption {
      type = lib.types.str;
      description = "Network for the Traefik docker provider";
      default = "traefik-proxy";
    };
  };

  config = lib.mkIf cfg.enable {
    services.podman.networks.${cfg.network} = {};
  };
}
