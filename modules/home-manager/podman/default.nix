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
    # TODO: Remove with 25.05
    home.packages = [cfg.package];

    services.podman = {
      enable = true;
      package = cfg.package;
    };

    # Enable podman socket systemd service in order for containers like Traefik to work
    xdg.configFile."systemd/user/sockets.target.wants/podman.socket".source = lib.mkIf cfg.enableSocket "${pkgs.podman}/share/systemd/user/podman.socket";

    # Fix for https://github.com/nix-community/home-manager/issues/6146
    # TODO: Remove after 25.05
    xdg.configFile."systemd/user/podman-user-wait-network-online.service.d/50-exec-search-path.conf".text = ''
      [Service]
      ExecSearchPath=${lib.makeBinPath (with pkgs; [bashInteractive systemd coreutils])}:/bin
    '';
  };
}
