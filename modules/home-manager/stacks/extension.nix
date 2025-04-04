{pkgs, lib, config, ...}:

let 
  globalConf = config;
in
{
    # Extend the podman options in order to custom build custom abstraction
  options.services.podman.containers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({config, ...}: {
      options = with lib;{
        dependsOn = mkOption {
          type = types.listOf types.str;
          default = [];
          apply = map (d: "podman-${d}.service");
        };

        stack = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Stack that a container is part of";
        };
      };

      config = {
        autoUpdate = lib.mkIf (lib.hasSuffix ":latest" config.image) (lib.mkDefault "registry");
        volumes  = ["/etc/localtime:/etc/localtime:ro"];

        network = lib.optional (config.stack  != null) config.stack;
        # TODO: Can be removed with new Quadlet generator?
        # https://github.com/containers/podman/issues/24637
        dependsOn = ["user-wait-network-online"];
        extraConfig = {
          # Theres some issues with healthchecks transient systemd service not being created. Disable for now
          # https://github.com/containers/podman/issues/25034#issuecomment-2600582885
          # Manually add systemd to PATH until PR is merged: https://github.com/nix-community/home-manager/pull/6659
          Service.Environment = "PATH=${
            builtins.concatStringsSep ":" [
              "/run/wrappers/bin"
              "/run/current-system/sw/bin"
              "${pkgs.systemd}/bin"
          ]}";


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

  # For every stack, define a default network.
  config.services.podman.networks = 
  let
    stacks = config.services.podman.containers 
      |> builtins.attrValues 
      |> builtins.filter (c: c.stack != null)
      |> builtins.map (c: c.stack);
  in
  lib.genAttrs stacks (s: lib.mkDefault {driver = "bridge";});
}