{
  lib,
  config,
  pkgs,
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
        "core"
        "fastfetch"
        "git"
        "shells"
        "sops"
        "starship"
        "stylix"
        "vscode"
        "neovim"
        "golang"
      ];
    }
  ];

  home.stateVersion = "24.11";
  sops.secrets."ssh_authorized_keys".path = "${config.home.homeDirectory}/.ssh/authorized_keys";
  tarow = {
    facts.ip4Address = "10.1.1.99";
    core.configLocation = "~/nix-config#homeserver";

    podman = rec {
      hostIP4Address = config.tarow.facts.ip4Address;
      hostUid = config.tarow.facts.uid;
      defaultTz = "Europe/Berlin";
      storageBaseDir = "${config.home.homeDirectory}/stacks";
      externalStorageBaseDir = "/mnt/hdd1";

      stacks = {
        adguard.enable = false;
        aiostreams = {
          enable = true;
          envFile = config.sops.secrets."aiostreams/env".path;
        };
        audiobookshelf.enable = true;
        beszel = {
          enable = false;
          ed25519PrivateKeyFile = config.sops.secrets."beszel/ssh_key".path;
          ed25519PublicKeyFile = config.sops.secrets."beszel/ssh_pub_key".path;
        };
        blocky = {
          enable = true;
          enableGrafanaDashboard = true;
          enablePrometheusExport = true;
          containers.blocky.homepage.settings.href = "${config.tarow.podman.stacks.monitoring.containers.grafana.traefik.serviceDomain}/d/blocky";
        };
        calibre.enable = false;
        changedetection.enable = true;
        crowdsec = {
          enable = true;
          envFile = config.sops.secrets."crowdsec/env".path;
        };
        dockdns = {
          enable = true;
          envFile = config.sops.secrets."dockdns/env".path;
          settings.domains = let
            domain = stacks.traefik.domain;
          in [
            {
              name = domain;
              a = hostIP4Address;
            }
            {
              name = "*.${domain}";
              a = hostIP4Address;
            }
            {
              name = "vpn.${domain}";
            }
          ];
        };
        dozzle.enable = true;
        dozzle.containers.dozzle.traefik.middlewares = ["pocketid"];
        filebrowser.enable = true;
        forgejo.enable = false;
        healthchecks = {
          enable = true;
          envFile = config.sops.secrets."healthchecks/env".path;
        };
        homeassistant.enable = false;
        homepage = {
          enable = true;
          containers.homepage.volumes = ["${./background.jpg}:/app/public/images/background.jpg"];
          settings.background = {
            image = "/images/background.jpg";
            opacity = 50;
          };
          widgets = [
            {
              openweathermap = {
                units = "metric";
                cache = 5;
                apiKey.path = config.sops.secrets."OPENWEATHERMAP_API_KEY".path;
              };
            }
          ];
        };
        immich = {
          enable = true;
          envFile = config.sops.secrets."immich/env".path;
          db.envFile = config.sops.secrets."immich/db_env".path;
        };
        ittools.enable = false;
        karakeep = {
          enable = false;
          envFile = config.sops.secrets."karakeep/env".path;
        };
        mealie.enable = false;
        monitoring = {
          enable = true;
          grafana.dashboards = [./node-exporter-dashboard.json];
          prometheus.config.scrape_configs = [
            # Scrape configs from Node-Exporter (setup on system level)
            {
              job_name = "node";
              honor_timestamps = true;
              scrape_interval = "15s";
              scrape_timeout = "10s";
              metrics_path = "/metrics";
              scheme = "http";
              static_configs = [{targets = ["host.containers.internal:9191"];}];
            }
          ];
        };
        paperless = {
          enable = true;
          envFile = config.sops.secrets."paperless/env".path;
          db.envFile = config.sops.secrets."paperless/db_env".path;
          ftp.envFile = config.sops.secrets."paperless/ftp_env".path;
        };
        pocketid = {
          enable = true;
          traefik.envFile = config.sops.secrets."pocketId/traefikEnv".path;
        };
        skatcounter.enable = true;
        stirling-pdf.enable = true;
        streaming =
          {
            enable = true;
            gluetun = {
              vpnProvider = "airvpn";
              envFile = config.sops.secrets."gluetun/env".path;
            };
            qbittorrent.envFile = config.sops.secrets."qbittorrent/env".path;
          }
          // lib.genAttrs ["sonarr" "radarr" "bazarr" "prowlarr"] (name: {
            envFile = config.sops.secrets."servarr/${name}_env".path;
          });
        traefik = {
          enable = true;
          domain = "ntasler.de";
          envFile = config.sops.secrets."traefik/env".path;
          geoblock.allowedCountries = ["DE"];
        };
        uptime-kuma.enable = true;
        wg-easy = {
          enable = false;
          envFile = config.sops.secrets."wg-easy/env".path;
        };
        vaultwarden.enable = true;
      };
    };
  };

  # On Remote SSH connections, settings in the ~/.config/Code folder won't be honored.
  # As a workaround, link the settings.json generated by HM to ~/.vscode-server dir used by Remote Code Server.
  home.file.".vscode-server/data/Machine/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/Code/User/settings.json";
}
