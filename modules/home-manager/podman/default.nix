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
      default = pkgs.unstable.podman.override {
        extraPackages = [pkgs.nftables];
      };
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
    # TODO: Remove with 25.05
    home.packages = [cfg.package];

    services.podman = {
      enable = true;
      package = cfg.package;
    };

    # Enable podman socket systemd service in order for containers like Traefik to work
    xdg.configFile."systemd/user/sockets.target.wants/podman.socket".source = lib.mkIf cfg.enableSocket "${cfg.package}/share/systemd/user/podman.socket";
    xdg.configFile."systemd/user" = {
      source = lib.mkIf cfg.enableSocket "${cfg.package}/share/systemd/user";
      recursive = true;
    };

    # Fix for https://github.com/nix-community/home-manager/issues/6146
    # TODO: Remove after 25.05
    xdg.configFile."systemd/user/podman-user-wait-network-online.service.d/50-exec-search-path.conf".text = ''
      [Service]
      ExecSearchPath=${lib.makeBinPath (with pkgs; [bashInteractive systemd coreutils])}:/bin
    '';

    xdg.configFile = {
      "containers/containers.conf".text = ''
        [network]
        dns_bind_port=1153
        firewall_driver="nftables"
      '';
      "containers/policy.json".text = ''
        {
          "default": [
            {
              "type": "insecureAcceptAnything"
            }
          ],
          "transports": {
            "docker-daemon": {
              "": [
                {
                  "type": "insecureAcceptAnything"
                }
              ]
            }
          }
        }
      '';
      "containers/registries.conf".text = ''
        [registries.block]
        registries = []

        [registries.insecure]
        registries = []

        [registries.search]
        registries = ["docker.io"]
      '';
    };
  };
}
