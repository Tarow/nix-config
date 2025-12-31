{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    {
      #services.podman.containers = lib.mkForce {};
      #services.podman.networks = lib.mkForce {};
    }
    {
      tarow = lib.tarow.enableModules [
        "aichat"
        "audiobook-organizer"
        "cmdmark"
        "core"
        "fastfetch"
        "git"
        "housekeeping"
        "nh"
        "shells"
        "sops"
        "starship"
        "stylix"
        "vscode"
        "neovim"
        "golang"
        "podman"
        "scrutiny"
        "npsSettings"
      ];
    }
  ];

  home.packages = with pkgs; [isd];

  home.stateVersion = "24.11";
  sops.secrets."ssh_authorized_keys".path = "${config.home.homeDirectory}/.ssh/authorized_keys";
  tarow = {
    facts.ip4Address = "10.1.1.99";
    sops.extraSopsFiles = [../../secrets/homeserver/secrets.yaml];
  };

  nps = {
    storageBaseDir = "${config.home.homeDirectory}/stacks";
    externalStorageBaseDir = "/mnt/hdd1";

    stacks = {
      # General onfiguration for stacks provided in modules/home-manager/stacks/default.nix if necessary
      # Just enable them here or provide host-specific settings

      #dguard.enable = true;
      aiostreams.enable = true;
      audiobookshelf.enable = true;
      authelia.enable = true;
      #baikal.enable = true;

      bentopdf.enable = true;
      #beszel.enable = true;
      blocky.enable = true;
      booklore.enable = true;
      #bytestash.enable = true;
      #calibre.enable = true;
      #changedetection.enable = true;
      glance.enable = true;
      glance.containers.glance.traefik.subDomain = "glance";
      crowdsec.enable = true;
      davis.enable = true;
      dockdns.enable = true;
      docker-socket-proxy.enable = true;
      #donetick.enable = true;
      dozzle.enable = true;
      ephemera.enable = true;
      #filebrowser.enable = true;
      #filebrowser-quantum.enable = true;
      #freshrss.enable = true;
      #forgejo.enable = true;
      #free-games-claimer.enable = true;

      gatus.enable = true;
      #gatus.containers.gatus.extraEnv.GATUS_LOG_LEVEL = "DEBUG";
      guacamole.enable = true;
      #healthchecks.enable = true;

      #homeassistant.enable = true;
      homepage.enable = true;

      hortusfox.enable = true;

      immich.enable = true;
      it-tools.enable = true;
      jotty.enable = true;

      karakeep.enable = true;
      #kimai.enable = true;

      #kitchenowl.enable = true;
      lldap.enable = true;
      #komga.enable = true;
      mazanoke.enable = true;
      #mealie.enable = true;
      #memos.enable = true;
      #microbin.enable = true;
      monitoring = {
        enable = true;
        grafana.dashboards = [./node-exporter-dashboard.json];
        prometheus.settings.scrape_configs = [
          # Scrape configs from Node-Exporter (setup on system level)
          {
            job_name = "node";
            honor_timestamps = true;
            metrics_path = "/metrics";
            scheme = "http";
            static_configs = [{targets = ["host.containers.internal:9191"];}];
          }
        ];
      };
      #n8n.enable = true;
      #networking-toolbox.enable = true;

      norish.enable = true;
      ntfy.enable = true;

      #outline.enable = true;

      paperless.enable = true;
      #pocketid.enable = true;
      #romm.enable = true;
      skatcounter = {
        enable = true;
      };
      #sshwifty.enable = true;
      #stirling-pdf.enable = true;

      #storyteller.enable = true;
      streaming =
        {
          enable = true;
        }
        // lib.genAttrs ["radarr" "sonarr" "bazarr" "jellyfin"] (_: {enable = false;});

      #tandoor.enable = true;
      # timetracker.enable = true;
      traefik.enable = true;
      #uptime-kuma.enable = true;
      #vikunja.enable = true;
      vaultwarden.enable = true;

      #webtop.enable = true;
      #wg-easy.enable = true;
      #wg-portal.enable = true;
      yopass.enable = true;
    };
  };
}
