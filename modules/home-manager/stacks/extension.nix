{
  pkgs,
  lib,
  config,
  ...
}: let
  globalConf = config;
in {
  # Extend the podman options in order to custom build custom abstraction
  options.services.podman.containers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({
      name,
      config,
      ...
    }: {
      options = with lib; {
        dependsOn = mkOption {
          type = types.listOf types.str;
          default = [];
          apply = map (d: "podman-${d}${
            if lib.hasInfix "." d
            then ""
            else ".service"
          }");
        };

        socketActivation = mkOption {
          type = types.listOf (types.submodule {
            options = {
              port = mkOption {
                type = types.port;
              };
              fileDescriptorName = mkOption {
                type = types.nullOr types.str;
                default = null;
              };
            };
          });
          default = [];
        };

        stack = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Stack that a container is part of";
        };
      };

      config = {
        autoUpdate = lib.mkIf (lib.hasSuffix ":latest" config.image) (lib.mkDefault "registry");
        volumes = ["/etc/localtime:/etc/localtime:ro"];

        network = lib.mkIf (config.stack != null) [config.stack];
        dependsOn = map (sa: "${name}-${toString sa.port}.socket") config.socketActivation;
        extraConfig = {
          # Theres some issues with healthchecks transient systemd service not being created. Disable for now
          # https://github.com/containers/podman/issues/25034#issuecomment-2600582885
          # Manually add systemd to PATH until PR is merged: https://github.com/nix-community/home-manager/pull/6659
          Service.Environment = "PATH=${
            builtins.concatStringsSep ":" [
              "/run/wrappers/bin"
              "/run/current-system/sw/bin"
              "${pkgs.systemd}/bin"
            ]
          }";

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

  config = {
    # For every stack, define a default network.
    services.podman.networks = let
      stacks =
        config.services.podman.containers
        |> builtins.attrValues
        |> builtins.filter (c: c.stack != null)
        |> builtins.map (c: c.stack);
    in
      lib.genAttrs stacks (s: lib.mkDefault {driver = "bridge";});

    # Create sockets for socketActivated containers
    systemd.user.sockets = let
      containers = lib.filterAttrs (n: v: v.socketActivation != []) config.services.podman.containers;
      mkSockets = name: container:
        map (sa:
          lib.nameValuePair "podman-${name}-${toString sa.port}" {
            Socket.ListenStream = "0.0.0.0:${toString sa.port}";
            Socket.ListenDatagram = "0.0.0.0:${toString sa.port}";
            Socket.Service = "podman-${name}.service";
            Socket.FileDescriptorName = lib.mkIf (sa.fileDescriptorName != null) sa.fileDescriptorName;
            Install.WantedBy = ["sockets.target"];
          })
        container.socketActivation;
      sockets = (lib.mapAttrsToList mkSockets containers) |> lib.flatten |> lib.listToAttrs;
    in
      sockets;
  };
}
