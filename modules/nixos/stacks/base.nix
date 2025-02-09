{
  name,
  port,
  hostPort ? port,
}: {
  lib,
  config,
  ...
}: let
  cfg = config.tarow.stacks.${name};

  stack = {
    networks.${config.tarow.stacks.traefik.network}.external = lib.mkIf cfg.addToTraefik true;
    services.${name}.service = lib.mkMerge [
      {
        container_name = name;
        restart = "unless-stopped";
        ports = lib.lists.optional (!cfg.addToTraefik && port != null) "${toString hostPort}:${toString port}";
      }
      (lib.mkIf cfg.addToTraefik {
        labels = import ./traefik/labels.nix {
          inherit name port config lib;
        };
        networks = [config.tarow.stacks.traefik.network];
      })
    ];
  };
in {
  options.tarow.stacks.${name} = with lib; {
    enable = options.mkEnableOption name;
    addToTraefik = options.mkOption {
      type = types.bool;
      default = config.tarow.stacks.traefik.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.arion.projects.${name}.settings = stack;
  };
}
