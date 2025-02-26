{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.stacks;
in {
  imports =
    lib.tarow.readSubdirs ./.
    ++ [(lib.mkAliasOptionModule ["tarow" "containers"] ["services" "podman" "containers"])];

  # Extend the podman options in order to custom build custom abstraction
  options.services.podman.containers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
      options = {
        dependsOn = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          apply = map (d: "podman-${d}.service");
        };
      };

      config = {
        # TODO: Can be removed with new Quadlet generator?
        # https://github.com/containers/podman/issues/24637
        dependsOn = ["user-wait-network-online"];
        extraConfig = {
          Unit.Requires = config.dependsOn;
          Unit.After = config.dependsOn;

          # Automatically create host directories for volumes if they don't exist
          Service.ExecStartPre = let
            volumes = map (v: lib.head (lib.splitString ":" v)) (config.volumes or []);
            volumeDirs = lib.filter (v: lib.hasInfix "/" v) volumes;
          in "${lib.getExe (pkgs.writeShellApplication {
            name = "setupVolumes";
            runtimeInputs = [pkgs.coreutils];
            text = (map (v: "[ -e ${v} ] || mkdir -p ${v}") volumeDirs) |> lib.concatStringsSep "\n";
          })}";
        };
      };
    }));
  };

  options.tarow.stacks = {
    enable = lib.mkEnableOption "stacks";
    defaultUid = lib.mkOption {
      type = lib.types.int;
      default = 0;
    };
    defaultGid = lib.mkOption {
      type = lib.types.int;
      default = 0;
    };
    defaultTz = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Berlin";
    };
    storageBaseDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/niklas/.stacks";
    };
    mediaStorageBaseDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/hdd1/media";
    };
  };
  config = lib.mkIf cfg.enable {
     tarow.podman.enable = true;
  };
}
