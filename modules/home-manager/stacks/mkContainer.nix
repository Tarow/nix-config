{
  name,
  stackName ? name,
  port,
  hostPort ? port,
  container ? {},
}: {
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.containers.${name};
  stackCfg = config.tarow.stacks.${stackName};

  volumes = map (v: lib.head (lib.splitString ":" v)) (container.volumes or []);
  volumeDirs = lib.filter (v: lib.hasInfix "/" v) volumes;

  finalContainer = lib.mkMerge [
    {
      extraConfig.Service.ExecStartPre = map (v: "${pkgs.coreutils}/bin/mkdir -p ${v}") volumeDirs;
    }
    {
      ports = lib.lists.optional (!cfg.addToTraefik && port != null) "${toString hostPort}:${toString port}";
      network = lib.lists.optional (stackName != null) stackName;
    }
    (lib.mkIf cfg.addToTraefik {
      labels = import ./traefik/labels.nix {
        inherit name port config lib;
      };
      network = [
        config.tarow.stacks.traefik.network
      ];
    })
    container
  ];
in {
  options.tarow = with lib; {
    stacks.${stackName}.enable = options.mkEnableOption stackName;
    containers.${name}.addToTraefik = options.mkOption {
      type = types.bool;
      default = config.tarow.stacks.traefik.enable;
    };
  };

  config = lib.mkIf stackCfg.enable {
    services.podman.enable = true;
    services.podman.containers.${name} = finalContainer;
    services.podman.networks.${name} = {};
  };
}
