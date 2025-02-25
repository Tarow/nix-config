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
        extraConfig = {
          Unit.Requires = config.dependsOn;
          Unit.After = config.dependsOn;

          # Automatically create host directories for volumes if they don't exist
          Service.ExecStartPre = let 
            volumes = map (v: lib.head (lib.splitString ":" v)) (config.volumes or []);
            volumeDirs = lib.filter (v: lib.hasInfix "/" v) volumes; 
          in 
            "${lib.getExe (pkgs.writeShellApplication {
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
    home.packages = with pkgs; [unstable.podman];
    services.podman.enable = true;
    # Enable podman socket systemd service in order for containers like Traefik to work
    xdg.configFile."systemd/user/sockets.target.wants/podman.socket".source = "${pkgs.podman}/share/systemd/user/podman.socket";

    # Fix for https://github.com/nix-community/home-manager/issues/6146
    # TODO: Remove after 25.05
    xdg.configFile."systemd/user/podman-user-wait-network-online.service.d/50-exec-search-path.conf".text = ''
      [Service]
      ExecSearchPath=${pkgs.bashInteractive}/bin:${pkgs.systemd}/bin:/bin
    '';
  };
}
