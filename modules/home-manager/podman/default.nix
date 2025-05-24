{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.podman;
in {
  options.tarow.podman = with lib; {
    enable = mkEnableOption "Podman";
    package = mkOption {
      type = types.package;
      default = pkgs.podman;
    };
    enableSocket = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    socketLocation = lib.mkOption {
      type = lib.types.str;
      default = "/run/user/${toString config.tarow.facts.uid}/podman/podman.sock";
      readOnly = true;
    };
  };
  config = lib.mkIf cfg.enable {
    services.podman = {
      enable = true;
      package = cfg.package;

      settings = {
        containers.network.dns_bind_port = 1153;
        policy = {
          default = [{type = "insecureAcceptAnything";}];
          transports = {
            docker-daemon = {
              "" = [{type = "insecureAcceptAnything";}];
            };
          };
        };
        registries = {
          search = ["docker.io"];
          insecure = [];
          block = [];
        };
      };
    };

    # Enable podman socket systemd service in order for containers like Traefik to work
    xdg.configFile."systemd/user/sockets.target.wants/podman.socket".source = lib.mkIf cfg.enableSocket "${cfg.package}/share/systemd/user/podman.socket";
    xdg.configFile."systemd/user" = {
      source = lib.mkIf cfg.enableSocket "${cfg.package}/share/systemd/user";
      recursive = true;
    };

    programs.fish.shellAbbrs = {
      psh = {
        expansion = "podman exec -it % /bin/sh";
        setCursor = true;
      };
      pl = "podman logs";
      plf = "podman logs -f";
    };
  };
}
