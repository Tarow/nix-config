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
        containers.blocky = {
          homepage.settings.href = "${config.tarow.podman.stacks.monitoring.containers.grafana.traefik.serviceDomain}/d/blocky";
          gatus = {
            enable = true;
            settings = {
              url = "host.containers.internal";
              dns = {
                query-name = config.tarow.podman.stacks.traefik.domain;
                query-type = "A";
              };
              conditions = [
                "[DNS_RCODE] == NOERROR"
              ];
            };
          };
        };
      };

      crowdsec = {
        envFile = config.sops.secrets."crowdsec/env".path;
      };
      dockdns = {
        envFile = config.sops.secrets."dockdns/env".path;
        settings.dns.purgeUnknown = true;
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
      gatus = {
        db.type = "postgres";
        db.envFile = config.sops.secrets."gatus/dbEnv".path;
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
        env = {
          PAPERLESS_OCR_LANGUAGES = "eng deu";
          PAPERLESS_OCR_LANGUAGE = "eng+deu";
        };
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
        domain = "ntasler.de";
        envFile = config.sops.secrets."traefik/env".path;
        geoblock.allowedCountries = ["DE"];
        enablePrometheusExport = true;
        enableGrafanaMetricsDashboard = true;
        enableGrafanaAccessLogDashboard = true;
      };

      wg-easy = {
        envFile = config.sops.secrets."wg-easy/env".path;
        containers.wg-easy.environment.DISABLE_IPV6 = true;
      };
      wg-portal = {
        settings.core = {
          admin_user = "$ADMIN_USER";
          admin_password = "$ADMIN_PASSWORD";
        };
        settings.advanved.use_ip_v6 = false;
        envFile = config.sops.secrets."wg-portal/env".path;
      };
    };
  };
}
