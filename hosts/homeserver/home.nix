{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    {
      tarow.podman.stacks.beszel = {
        enable = true;
        ed25519PrivateKeyFile = config.sops.secrets."beszel/ssh_key".path;
        ed25519PublicKeyFile = config.sops.secrets."beszel/ssh_pub_key".path;
      };
    }
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
      #package = pkgs.unstable.podman;
      hostIP4Address = config.tarow.facts.ip4Address;
      hostUid = config.tarow.facts.uid;
      defaultTz = "Europe/Berlin";
      storageBaseDir = "${config.home.homeDirectory}/stacks";
      externalStorageBaseDir = "/mnt/hdd1";

      stacks = {
        adguard.enable = false;
        blocky = {
          enable = true;
          enableGrafanaDashboard = true;
          enablePrometheusExport = true;
          # containers.blocky.homepage.settings.widget.enable = true;
          containers.blocky.homepage.settings.href = "${config.tarow.podman.stacks.monitoring.containers.grafana.traefik.serviceDomain}/d/blocky";
        };

        aiostreams = {
          enable = true;
          envFile = config.sops.secrets."aiostreams/env".path;
        };
        audiobookshelf.enable = true;
        calibre.enable = false;
        changedetection.enable = true;
        crowdsec = {
          enable = true;
          envFile = config.sops.secrets."crowdsec/env".path;
        };
        dozzle.enable = true;
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
        filebrowser.enable = true;
        healthchecks = {
          enable = true;
          envFile = config.sops.secrets."healthchecks/env".path;
        };
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
        skatcounter.enable = true;
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
        stirling-pdf.enable = true;

        paperless = {
          enable = true;
          envFile = config.sops.secrets."paperless/env".path;
          db.envFile = config.sops.secrets."paperless/db_env".path;
          ftp.envFile = config.sops.secrets."paperless/ftp_env".path;
        };

        wg-easy = {
          enable = false;
          envFile = config.sops.secrets."wg-easy/env".path;
        };

        uptime-kuma.enable = true;
        traefik = {
          enable = true;
          domain = "ntasler.de";
          envFile = config.sops.secrets."traefik/env".path;
          geoblock.allowedCountries = ["DE"];
        };
      };
    };
  };

  # On Remote SSH connections, settings in the ~/.config/Code folder won't be honored.
  # As a workaround, link the settings.json generated by HM to ~/.vscode-server dir used by Remote Code Server.
  home.file.".vscode-server/data/Machine/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/Code/User/settings.json";
}
