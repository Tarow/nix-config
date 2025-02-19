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

  # Extend the podman options, so host volumes are automatically created if they don't exist
  options.services.podman.containers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
      config.extraConfig.Service = let 
        volumes = map (v: lib.head (lib.splitString ":" v)) (config.volumes or []);
        volumeDirs = lib.filter (v: lib.hasInfix "/" v) volumes;
      in{
        ExecStartPre = "${lib.getExe (pkgs.writeShellApplication {
          name = "setupVolumes";
          runtimeInputs = [pkgs.coreutils];
          text = (map (v: "[ -e ${v} ] || mkdir -p ${v}") volumeDirs) |> lib.concatStringsSep "\n";
        })}";
      };
    }));
  };

  options.tarow.stacks = {
    enable = lib.mkEnableOption "stacks";
    defaultUid = lib.mkOption {
      type = lib.types.int;
      default = 0; # Maps to my own user id when running rootless podman.
    };
    defaultGid = lib.mkOption {
      type = lib.types.int;
      default = 0; # Maps to my own user gid when running rootless podman.
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
    home.packages = with pkgs; [unstable.podman];
    services.podman.enable = true;
    # Enable podman socket systemd service in order for containers like Traefik to work
    xdg.configFile."systemd/user/sockets.target.wants/podman.socket".source = "${pkgs.podman}/share/systemd/user/podman.socket";
  };
}
