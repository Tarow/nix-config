{
  lib,
  config,
  ...
}: let
  dozzleEnabled = config.tarow.stacks.dozzle.enable;
in {
  # If a container is part of a stack, add some labels so dozzle recognizes it as a stack
  options.services.podman.containers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
      config = lib.mkIf (dozzleEnabled && (config.stack != null)) {
        labels."dev.dozzle.group" = config.stack;
      };
    }));
  };
}
