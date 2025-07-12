# Configure stacks that require configuration.
# Stacks are only configured here, but enabled in each hosts configuration.
{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [inputs.nix-podman-stacks.homeModules.all];

  config.tarow.podman = rec {
    hostIP4Address = config.tarow.facts.ip4Address;
    hostUid = config.tarow.facts.uid;
    defaultTz = "Europe/Berlin";

    stacks = {
      aiostreams = {
        envFile = config.sops.secrets."aiostreams/env".path;
      };

      beszel = {
        ed25519PrivateKeyFile = config.sops.secrets."beszel/ssh_key".path;
        ed25519PublicKeyFile = config.sops.secrets."beszel/ssh_pub_key".path;
      };
      blocky = {
        enableGrafanaDashboard = true;
        enablePrometheusExport = true;
        containers.blocky.homepage.settings.href = "${config.tarow.podman.stacks.monitoring.containers.grafana.traefik.serviceDomain}/d/blocky";
      };

      crowdsec = {
        envFile = config.sops.secrets."crowdsec/env".path;
      };
      dockdns = {
        envFile = config.sops.secrets."dockdns/env".path;
        settings.domains = let
          domain = config.tarow.podman.stacks.traefik.domain or "";
        in
          lib.optionals (domain != "") [
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

      healthchecks = {
        envFile = config.sops.secrets."healthchecks/env".path;
      };

      homepage = {
        bookmarks = import ./homepage-bookmarks.nix;
        containers.homepage.volumes = ["${./homepage-background.jpg}:/app/public/images/background.jpg"];
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
        envFile = config.sops.secrets."immich/env".path;
        db.envFile = config.sops.secrets."immich/db_env".path;
      };

      karakeep = {
        envFile = config.sops.secrets."karakeep/env".path;
      };

      microbin = {
        envFile = config.sops.secrets."microbin/env".path;
      };
      ntfy = {
        envFile = config.sops.secrets."ntfy/env".path;
        enableGrafanaDashboard = true;
        enablePrometheusExport = true;
      };
      paperless = {
        envFile = config.sops.secrets."paperless/env".path;
        db.envFile = config.sops.secrets."paperless/db_env".path;
        ftp.envFile = config.sops.secrets."paperless/ftp_env".path;
      };
      pocketid = {
        traefik.envFile = config.sops.secrets."pocketId/traefikEnv".path;
      };
      streaming =
        {
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
        envFile = config.sops.secrets."traefik/env".path;
        geoblock.allowedCountries = ["DE"];
        enablePrometheusExport = true;
        enableGrafanaMetricsDashboard = true;
        enableGrafanaAccessLogDashboard = true;
      };

      wg-easy = {
        envFile = config.sops.secrets."wg-easy/env".path;
      };
    };
  };
}
