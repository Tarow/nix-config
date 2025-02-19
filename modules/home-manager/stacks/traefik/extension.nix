{
  lib,
  config,
  ...
}: let
  stackCfg = config.tarow.stacks.traefik;

  getPort = port: index:
    if (builtins.isInt port)
    then builtins.toString port
    else builtins.elemAt (builtins.match "([0-9]+):([0-9]+)" port) index;
in {
  options.services.podman.containers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({
      name,
      config,
      ...
    }: let
      traefikCfg = config.traefik;
      port = config.port;
    in {
      options = with lib; {
        # Main port that will be used by traefik. If traefik is disabled, it will be added to the "ports" section
        port = mkOption {
          type = types.nullOr (types.oneOf [types.str types.int]);
          default = null;
        };
        traefik = with lib; {
          name = options.mkOption {
            type = types.nullOr types.str;
            default = null;
          };
        };
      };

      config = let
        enableTraefik = stackCfg.enable && traefikCfg.name != null;
        hostPort = getPort port 0;
        containerPort = getPort port 1;
      in {
        labels = lib.optionalAttrs enableTraefik {
          "traefik.enable" = "true";
          "traefik.http.routers.${name}.rule" = ''Host(\`${traefikCfg.name}.${stackCfg.domain}\`)'';
          "traefik.http.routers.${name}.entrypoints" = "web";
          "traefik.http.services.${name}.loadbalancer.server.port" = containerPort;
        };
        network = lib.optional enableTraefik stackCfg.network;
        ports = lib.optional (!enableTraefik && (port != null)) "${hostPort}:${containerPort}";
      };
    }));
  };
}
