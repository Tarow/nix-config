{
  lib,
  config,
  ...
}: {
  imports = [
    {
      tarow = lib.tarow.enableModules [
        "core"
        "git"
        "shells"
        "sops"
        "stylix"
      ];
    }
  ];

  home.stateVersion = "24.11";

  sops.secrets."ssh_authorized_keys".path = "${config.home.homeDirectory}/.ssh/authorized_keys";

  tarow = {
    facts.ip4Address = "10.1.1.99";
    core.configLocation = "~/nix-config#homeserver";

    stacks = {
      enable = true;
      adguard.enable = true;
      audiobookshelf.enable = true;
      calibre.enable = true;
      changedetection.enable = true;
      dozzle.enable = true;
      dockdns.enable = true;
      filebrowser.enable = true;
      healthchecks.enable = true;
      homepage.enable = true;
      monitoring.enable = true;
      streaming.enable = true;
      stirling-pdf.enable = true;
      immich.enable = true;
      paperless.enable = true;
      wg-easy.enable = true;
      uptime-kuma.enable = true;
      traefik = {
        enable = true;
        domain = "ntasler.de";
      };
    };
  };

  # Also expose port on localhost, because we configure NixOS node-exporter to publish metrics
  #services.podman.containers.prometheus.ports = lib.mkIf (config.tarow.stacks.monitoring.enable) ["9090:9090"];
  #services.podman.containers = lib.mkForce {};
}
