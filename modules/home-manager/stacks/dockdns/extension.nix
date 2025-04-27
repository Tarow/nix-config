{
  lib,
  config,
  ...
}: let
  dockdnsEnabled = config.tarow.stacks.dockdns.enable;
  traefikEnabled = config.tarow.stacks.traefik.enable;
in {
  # If a container has the public middleware, create a record for it
  options.services.podman.containers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
      config = let
        traefikCfg = config.traefik;
        isPublic = builtins.elem "public" traefikCfg.middlewares;
      in
        lib.mkIf (dockdnsEnabled && traefikEnabled && isPublic) {
          labels."dockdns.name" = traefikCfg.serviceHost;
        };
    }));
  };
}
