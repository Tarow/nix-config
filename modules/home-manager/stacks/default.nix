# Configure stacks that require configuration.
# Stacks are only configured here, but enabled in each hosts configuration.
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  domain = "ntasler.de";
  lldapUsers = with config.nps.stacks; {
    readonly = {
      id = "readonly";
      displayName = "readonly";
      password_file = config.sops.secrets."lldap/readonly_password".path;
      email = "readonly@${domain}";
      groups = [lldap.readOnlyGroup];
    };
    niklas = {
      id = "niklas";
      email = "niklas@${domain}";
      password_file = config.sops.secrets."users/niklas/password".path;
      displayName = "Niklas";
      groups = [
        monitoring.grafana.oidc.adminGroup
        immich.oidc.adminGroup
        streaming.jellyfin.oidc.adminGroup
        lldap.adminGroup
        mealie.oidc.adminGroup
        wg-portal.oidc.adminGroup
        filebrowser-quantum.oidc.adminGroup
        audiobookshelf.oidc.adminGroup
        timetracker.oidc.adminGroup
        romm.oidc.adminGroup
        jotty.oidc.adminGroup

        # No group-based admin access supported yet, just user-roles
        karakeep.oidc.userGroup
        paperless.oidc.userGroup
        gatus.oidc.userGroup
        vikunja.oidc.userGroup
        freshrss.oidc.userGroup
        outline.oidc.userGroup
        storyteller.oidc.userGroup
        komga.oidc.userGroup
        tandoor.oidc.userGroup
        kitchenowl.oidc.userGroup
        norish.oidc.adminGroup
        vaultwarden.oidc.userGroup
        booklore.oidc.userGroup
        streaming.qui.oidc.userGroup
        papra.oidc.userGroup
      ];
    };
    selma = {
      email = "selma@${domain}";
      displayName = "Selma";
      groups = [
        streaming.jellyfin.oidc.userGroup
        mealie.oidc.userGroup
        immich.oidc.userGroup
        paperless.oidc.userGroup
        vikunja.oidc.userGroup
        audiobookshelf.oidc.adminGroup
        timetracker.oidc.userGroup
        tandoor.oidc.userGroup
        norish.oidc.userGroup
        booklore.oidc.userGroup
      ];
    };
    guest = {
      email = "guest@${domain}";
      password_file = config.sops.secrets."users/guest/password".path;
      displayName = "Guest";
    };
    test = {
      email = "test@${domain}";
      password_file = config.sops.secrets."users/test/password".path;
      displayName = "Testuser";
      groups = [
        wg-portal.oidc.userGroup
        freshrss.oidc.userGroup
        outline.oidc.userGroup
        tandoor.oidc.userGroup
      ];
    };
  };
in {
  imports = [
    inputs.nix-podman-stacks.homeModules.nps
    {
      # Add default config to every container
      options.services.podman.containers = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule ({config, ...}: {
            #homepage.settings.description = lib.mkIf (config.homepage.category != null) (lib.mkForce null);
            extraConfig.Unit = {
              Wants = ["sops-nix.service"];
              After = ["sops-nix.service"];
            };
          })
        );
      };
    }
  ];

  options.tarow.npsSettings.enable = lib.mkEnableOption "Settings for Nix Podman Stacks";

  config.nps = lib.mkIf config.tarow.npsSettings.enable {
    hostIP4Address = config.tarow.facts.ip4Address;
    hostUid = config.tarow.facts.uid;
    defaultTz = "Europe/Berlin";

    stacks = {
      aiostreams = {
        secretKeyFile = config.sops.secrets."aiostreams/secret_key".path;
        extraEnv = {
          REGEX_FILTER_ACCESS = "all";
          TMDB_ACCESS_TOKEN.fromFile = config.sops.secrets."aiostreams/tmdb_access_token".path;
          TMDB_API_KEY.fromFile = config.sops.secrets."aiostreams/tmdb_api_key".path;
          FORCED_REALDEBRID_API_KEY.fromFile = config.sops.secrets."aiostreams/rd_api_key".path;
          ALLOWED_REGEX_PATTERNS_URLS = ''[\"https://raw.githubusercontent.com/Vidhin05/Releases-Regex/main/merged-anime-regexes.json\",\"https://raw.githubusercontent.com/Vidhin05/Releases-Regex/main/merged-regexes.json\"]'';
        };
      };
      audiobookshelf = {
        oidc = {
          registerClient = true;
          clientSecretHash.toHash = config.sops.secrets."audiobookshelf/authelia/client_secret".path;
        };
      };
      authelia = {
        jwtSecretFile = config.sops.secrets."authelia/jwt_secret".path;
        sessionSecretFile = config.sops.secrets."authelia/session_secret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/encryption_key".path;
        ldap = {
          username = lldapUsers.readonly.id;
          passwordFile = lldapUsers.readonly.password_file;
        };
        oidc = {
          enable = true;
          hmacSecretFile = config.sops.secrets."authelia/oidc_hmac_secret".path;
          jwksRsaKeyFile = config.sops.secrets."authelia/oidc_rsa_pk".path;

          # Define a dummy client with two_factor to enable the related settings
          clients.dummy = {
            public = true;
            authorization_policy = "two_factor";
            redirect_uris = [];
          };
        };
        settings.log.level = "debug";
        sessionProvider = "redis";

        containers.authelia = {
          traefik.subDomain = "auth";
          expose = true;
        };
      };

      blocky = {
        enableGrafanaDashboard = true;
        enablePrometheusExport = true;
        containers.blocky = {
          homepage.settings.href = "${config.nps.containers.grafana.traefik.serviceUrl}/d/blocky";
          glance.url = "${config.nps.containers.grafana.traefik.serviceUrl}/d/blocky";
          gatus = {
            enable = true;
            settings = {
              url = "host.containers.internal";
              dns = {
                query-name = config.nps.stacks.traefik.domain;
                query-type = "A";
              };
              conditions = [
                "[DNS_RCODE] == NOERROR"
              ];
            };
          };
        };
      };

      booklore = {
        oidc = {
          registerClient = true;
        };
        db = {
          userPasswordFile = config.sops.secrets."booklore/db_user_password".path;
          rootPasswordFile = config.sops.secrets."booklore/db_root_password".path;
        };
      };

      crowdsec = {
        extraEnv = {
          ENROLL_INSTANCE_NAME = "homeserver";
          ENROLL_KEY.fromFile = config.sops.secrets."crowdsec/enroll_key".path;
        };
        enableGrafanaDashboard = true;
        enablePrometheusExport = true;
      };
      davis = {
        adminPasswordFile = config.sops.secrets."davis/admin_password".path;
        db = {
          type = "mysql";
          userPasswordFile = config.sops.secrets."davis/db_user_password".path;
          rootPasswordFile = config.sops.secrets."davis/db_root_password".path;
        };

        containers.davis = {
          expose = true;
        };
      };
      dockdns = {
        extraEnv.NTASLER_DE_API_TOKEN.fromFile = config.sops.secrets."CLOUDFLARE_API_KEY".path;
        settings.dns.purgeUnknown = true;
        settings.log.level = "debug";
        settings.domains = let
          hostIP4Address = config.nps.hostIP4Address;
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
      donetick = {
        settings.is_user_creation_disabled = true;
        jwtSecretFile = config.sops.secrets."donetick/jwt_secret".path;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."donetick/authelia/client_secret".path;
        };
      };
      filebrowser-quantum = {
        mounts = {
          ${config.home.homeDirectory} = {
            path = config.home.homeDirectory;
            name = config.home.username;
          };
          ${config.nps.externalStorageBaseDir} = {
            path = "/hdd";
            name = "hdd";
          };
        };
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."filebrowser-quantum/authelia/client_secret".path;
        };
        settings.auth.methods.password.enabled = false;
      };

      free-games-claimer = {
        containers.free-games-claimer.exec = "node epic-games";
      };

      freshrss = {
        # First OIDC-logged-in account will have admin rights
        # See <https://freshrss.github.io/FreshRSS/en/admins/16_OpenID-Connect.html> for setup
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."freshrss/authelia/client_secret".path;
          cryptoKeyFile = config.sops.secrets."freshrss/authelia/crypto_key".path;
        };
      };
      gatus = {
        db = {
          type = "postgres";
          passwordFile = config.sops.secrets."gatus/postgresPassword".path;
        };

        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."gatus/authelia_client_secret".path;
        };

        # Needs Traefik for startup due to initial OIDC setup
        containers.gatus.wantsContainer = ["traefik"];
        containers.gatus.extraEnv = {
          NTFY_ACCESS_TOKEN.fromFile = config.sops.secrets."users/monitoring/ntfy_access_token".path;
          EXTERNAL_ENDPOINT_PUSH_TOKEN.fromFile = config.sops.secrets."gatus/external_endpoint_token".path;
        };
        settings = let
          mkAlert = {
            endpoint,
            extraSettings ? {},
          }: {
            alerts = [
              ({
                  enabled = config.nps.stacks.ntfy.enable;
                  type = "ntfy";
                  description = "Error for Gatus Healthcheck: ${endpoint.name}";
                }
                // extraSettings)
            ];
          };
        in {
          alerting.ntfy = {
            topic = "monitoring";
            url = "http://${config.nps.containers.ntfy.traefik.serviceAddressInternal}";
            token = "\${NTFY_ACCESS_TOKEN}";
            click = config.nps.containers.gatus.traefik.serviceUrl;
            default-alert = {
              description = "Gatus Healthcheck Failed";
              send-on-resolved = true;
              failure-threshold = 2;
              success-threshold = 1;
            };
          };
          endpoints = let
            general = [
              {
                name = "External IP";
                url = "icmp://vpn.${domain}";
                client.dns-resolver = "tcp://1.1.1.1:53";
                group = "ext_availability";
                conditions = [
                  "[CONNECTED] == true"
                ];
              }
              {
                name = "Relsat Server";
                url = "https://relsat.de";
                client.dns-resolver = "tcp://1.1.1.1:53";
                group = "ext_availability";
              }
            ];

            # Check that all exposed services are reachable via the public IP
            exposedContainers = config.services.podman.containers |> lib.filterAttrs (_: c: c.expose);
            exposedEndpointChecks =
              exposedContainers
              |> lib.mapAttrs (name: c: {
                url = c.traefik.serviceUrl;
                name = "${name} External";
                client.dns-resolver = "tcp://1.1.1.1:53";
                group = "ext_availability";
                headers.Accept = "text/html";
              })
              |> lib.attrValues;
          in
            (general ++ exposedEndpointChecks) |> map (e: (mkAlert {endpoint = e;}) // e);

          external-endpoints = let
            backups =
              ["Local" "Remote" "Relsat-Local" "Relsat-Remote"]
              |> map (name: {
                name = "Backup ${name}";
                group = "backups";
                token = "\${EXTERNAL_ENDPOINT_PUSH_TOKEN}";
                heartbeat.interval = "25h";
              });
          in
            backups
            |> map (e:
              (mkAlert {
                endpoint = e;
                extraSettings.failure-threshold = 1;
              })
              // e);
        };
      };

      glance = {
        settings.pages.home = {
          columns.start = {
            rank = 500;
            size = "small";
            widgets = [
              {
                type = "server-stats";
                servers = [
                  {
                    type = "local";
                    name = "Server";
                  }
                ];
              }
              {
                type = "bookmarks";
                groups = import ./glance-bookmarks.nix;
              }
              {
                type = "reddit";
                subreddit = "selfhosted";
                collapse-after = 3;
              }
            ];
          };

          columns.end = {
            rank = 1500;
            size = "small";
            widgets = [
              {
                type = "clock";
                time-format = "24h";
                date-format = "d MMMM yyyy";
                show-seconds = true;
                show-timezone = true;
                timezone = config.nps.defaultTz;
              }
              {
                type = "search";
                search-engine = "google";
                new-tab = true;
              }
              {
                type = "calendar";
                first-day-of-week = "monday";
              }
              {
                type = "weather";
                location = "Mönchengladbach, Germany";
              }
            ];
          };
        };
      };

      guacamole = {
        containers.guacamole = {
          forwardAuth = {
            enable = true;
            rules = [
              {
                policy = "two_factor";
              }
            ];
          };
        };
        userMappingXml = ''
          <user-mapping>
            <authorize username="${lldapUsers.niklas.id}" password="{{ file.Read `${lldapUsers.niklas.password_file}` }}">
                <connection name="Host SSH">
                    <protocol>ssh</protocol>
                    <param name="hostname">host.containers.internal</param>
                    <param name="port">22</param>
                    <param name="username">${lldapUsers.niklas.id}</param>
                    <param name="private-key">{{ file.Read `${config.sops.secrets."guacamole/ssh_private_key".path}` }}</param>
                    <param name="command">bash</param>
                </connection>
            </authorize>
          </user-mapping>
        '';
      };
      healthchecks = {
        secretKeyFile = config.sops.secrets."healthchecks/secret_key".path;
        superUserEmail = lldapUsers.niklas.email;
        superUserPasswordFile = config.sops.secrets."healthchecks/superuser_password".path;
        containers.healthchecks = {
          forwardAuth = {
            enable = true;
            rules = [
              {
                resources = ["^/ping/.*$"];
                policy = "bypass";
              }
            ];
          };
          extraEnv = {
            REMOTE_USER_HEADER = "HTTP_REMOTE_EMAIL";
          };
        };
      };
      homepage = {
        bookmarks = import ./homepage-bookmarks.nix;
        containers.homepage.volumes = [
          "${./homepage-background.jpg}:/app/public/images/background.jpg"
          "${pkgs.writeText "custom.js" (import ./homepage-customjs.nix config.nps.containers.dozzle.traefik.serviceUrl)}:/app/config/custom.js"
        ];
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

      hortusfox = {
        adminEmail = lldapUsers.niklas.email;
        containers.hortusfox.forwardAuth.enable = true;

        extraEnv = {
          PROXY_OVERWRITE_VALUES = true;
          PROXY_ENABLE = true;
          PROXY_HEADER_EMAIL = "Remote-Email";
          PROXY_HEADER_USERNAME = "Remote-User";
          PROXY_AUTO_SIGNUP = true;
          PROXY_WHITELIST = config.nps.stacks.traefik.ip4;
          PROXY_HIDE_LOGOUT = true;
        };
        db = {
          userPasswordFile = config.sops.secrets."hortusfox/db_user_password".path;
          rootPasswordFile = config.sops.secrets."hortusfox/db_root_password".path;
        };
      };

      immich = {
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."immich/authelia/client_secret".path;
        };
        db.passwordFile = config.sops.secrets."immich/db_password".path;
        settings = {
          oauth.autoLaunch = true;
          passwordLogin.enabled = false;
        };
      };

      jotty.oidc = {
        enable = true;
        clientSecretFile = config.sops.secrets."jotty/authelia/client_secret".path;
      };

      karakeep = {
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."karakeep/authelia/client_secret".path;
        };
        nextauthSecretFile = config.sops.secrets."karakeep/nextauth_secret".path;
        meiliMasterKeyFile = config.sops.secrets."karakeep/meili_master_key".path;

        containers.karakeep.extraEnv = {
          DISABLE_SIGNUPS = true;
          DISABLE_PASSWORD_AUTH = true;
        };
      };

      kimai = {
        adminEmail = lldapUsers.niklas.email;
        adminPasswordFile = config.sops.secrets."kimai/admin_password".path;
        db = {
          userPasswordFile = config.sops.secrets."kimai/db_user_password".path;
          rootPasswordFile = config.sops.secrets."kimai/db_root_password".path;
        };
      };

      kitchenowl = {
        jwtSecretFile = config.sops.secrets."kitchenowl/jwt_secret".path;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."kitchenowl/authelia/client_secret".path;
        };
      };

      komga = {
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."komga/authelia/client_secret".path;
        };
      };
      lldap = {
        baseDn = domain |> lib.splitString "." |> lib.concatMapStringsSep "," (p: "DC=${p}");
        jwtSecretFile = config.sops.secrets."lldap/jwtSecret".path;
        keySeedFile = config.sops.secrets."lldap/keySeed".path;
        adminPasswordFile = config.sops.secrets."lldap/adminPassword".path;
        bootstrap = {
          cleanUp = true;
          users = lldapUsers;
        };
      };

      mealie = {
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."mealie/authelia/client_secret".path;
        };
      };

      memos = {
        oidc = {
          registerClient = true;
          clientSecretHash.toHash = config.sops.secrets."memos/authelia/client_secret".path;
        };
        db = {
          passwordFile = config.sops.secrets."memos/db_password".path;
          type = "postgres";
        };
      };

      microbin = {
        extraEnv = {
          MICROBIN_ADMIN_USERNAME = "admin";
          MICROBIN_ADMIN_PASSWORD.fromFile = config.sops.secrets."microbin/admin_password".path;
          MICROBIN_UPLOADER_PASSWORD.fromFile = config.sops.secrets."microbin/uploader_password".path;
        };
      };

      monitoring = {
        grafana = {
          oidc = {
            enable = true;
            clientSecretFile = config.sops.secrets."grafana/authelia/client_secret".path;
          };
        };
        prometheus.rules.groups = let
          cpuThresh = 90;
          ramThresh = 85;
        in [
          {
            name = "resource.usage";
            interval = "30s";
            rules = [
              {
                alert = "HighCpuUsage";
                expr = ''100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > ${toString cpuThresh}'';
                for = "20m";
                labels = {
                  severity = "warning";
                };
                annotations = {
                  summary = "High CPU usage";
                  description = "CPU usage is above ${toString cpuThresh}% (current value: {{ $value }}%)";
                };
              }
              {
                alert = "HighMemoryUsage";
                expr = ''(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > ${toString ramThresh}'';
                labels = {
                  severity = "warning";
                };
                annotations = {
                  summary = "High memory usage";
                  description = "Memory usage is above ${toString ramThresh}% (current value: {{ $value }}%)";
                };
              }
            ];
          }
          # Test-Alert every sunday at 19:00 UTC time to verify alerting pipeline
          {
            name = "test.integration";
            interval = "1m";
            rules = [
              {
                alert = "WeeklyTestAlert";
                expr = ''
                  (day_of_week() == 0)
                  and (hour() == 18)
                  and (minute() >= 0)
                  and (minute() < 2)
                '';
                labels = {
                  severity = "test";
                };
                annotations = {
                  summary = "Weekly integration test: Prometheus → Alertmanager → ntfy";
                  description = "This is a scheduled test alert to verify the alerting pipeline.";
                };
              }
            ];
          }
        ];

        alertmanager = {
          enable = true;
          ntfy = {
            enable = true;
            tokenFile = config.sops.secrets."users/monitoring/ntfy_access_token".path;
            settings.ntfy.notification.topic = "monitoring";
          };
        };
      };

      norish = {
        masterKeyFile = config.sops.secrets."norish/master_key".path;
        db.passwordFile = config.sops.secrets."norish/db_password".path;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."norish/authelia/client_secret".path;
        };
      };

      ntfy = {
        extraEnv = {
          NTFY_WEB_PUSH_EMAIL_ADDRESS = "admin@${domain}";
          NTFY_WEB_PUSH_PUBLIC_KEY.fromFile = config.sops.secrets."ntfy/web_push_public_key".path;
          NTFY_WEB_PUSH_PRIVATE_KEY.fromFile = config.sops.secrets."ntfy/web_push_private_key".path;
        };
        settings = {
          enable-login = true;
          auth-default-access = "deny-all";
          auth-users = [
            "niklas:{{ file.Read `${config.sops.secrets."users/niklas/password_bcrypt".path}` }}:admin"
            "monitoring:{{ file.Read `${config.sops.secrets."users/monitoring/password_bcrypt".path}` }}:user"
          ];
          auth-access = [
            "monitoring:monitoring:rw"
          ];
          auth-tokens = [
            "monitoring:{{ file.Read `${config.sops.secrets."users/monitoring/ntfy_access_token".path}` }}"
          ];
        };
        enableGrafanaDashboard = true;
        enablePrometheusExport = true;
      };

      outline = {
        secretKeyFile = config.sops.secrets."outline/secret_key".path;
        utilsSecretFile = config.sops.secrets."outline/utils_secret".path;
        db.passwordFile = config.sops.secrets."outline/db_password".path;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."outline/authelia/client_secret".path;
        };
      };
      paperless = {
        enableTika = true;
        adminProvisioning = {
          username = "admin";
          passwordFile = config.sops.secrets."paperless/admin_password".path;
          email = "admin@example.com";
        };
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."paperless/authelia_client_secret".path;
        };
        secretKeyFile = config.sops.secrets."paperless/secret_key".path;
        extraEnv = {
          PAPERLESS_OCR_LANGUAGES = "eng deu";
          PAPERLESS_OCR_LANGUAGE = "eng+deu";
          PAPERLESS_DISABLE_REGULAR_LOGIN = true;
          PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
        };
        db = {
          passwordFile = config.sops.secrets."paperless/db_password".path;
        };
        ftp = {
          enable = true;
          passwordFile = config.sops.secrets."paperless/ftp_password".path;
        };
      };

      papra = {
        authSecretFile = config.sops.secrets."papra/auth_secret".path;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."papra/authelia/client_secret".path;
        };
      };

      romm = {
        authSecretKeyFile = config.sops.secrets."romm/auth_secret_key".path;
        romLibraryPath = "${config.nps.externalStorageBaseDir}/romm/library";
        extraEnv = {
          IGDB_CLIENT_ID.fromFile = config.sops.secrets."romm/igdb_client_id".path;
          IGDB_CLIENT_SECRET.fromFile = config.sops.secrets."romm/igdb_client_secret".path;
        };
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."romm/authelia/client_secret".path;
        };
        db = {
          userPasswordFile = config.sops.secrets."romm/db/user_password".path;
          rootPasswordFile = config.sops.secrets."romm/db/root_password".path;
        };
        igir = {
          enable = true;
          package = pkgs.unstable.igir;
        };
      };

      sshwifty = let
        privateKeyFile = "/run/secrets/ssh_pk";
        webPasswordFile = "/run/secrets/web_password";
      in {
        containers.sshwifty = {
          forwardAuth = {
            enable = true;
            rules = [{policy = "two_factor";}];
          };
          volumes = [
            "${config.sops.secrets."sshwifty/ssh_private_key".path}:${privateKeyFile}"
            "${config.sops.secrets."sshwifty/web_password".path}:${webPasswordFile}"
          ];
        };
        settings = {
          SharedKey = "{{ file.Read `${config.sops.secrets."sshwifty/web_password".path}`}}";
          Presets = [
            {
              Title = "SSH NixOS";
              Type = "SSH";
              Host = "host.containers.internal:22";
              Meta = {
                User = lldapUsers.niklas.id;
                Encoding = "utf-8";
                "Private Key" = "file://${privateKeyFile}";
                Authentication = "Private Key";
              };
            }
          ];
        };
      };

      storyteller = {
        secretKeyFile = config.sops.secrets."storyteller/secret_key".path;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."storyteller/authelia/client_secret".path;
        };
        containers.storyteller = {
          devices = ["/dev/dri:/dev/dri"];
          extraConfig.Service.ExecStartPost = [
            (lib.getExe (
              pkgs.writeShellApplication {
                name = "storyteller-admin-init";
                runtimeInputs = with pkgs; [podman coreutils sqlite libossp_uuid yq-go];
                text = import ./storyteller_init.nix {
                  username = lldapUsers.niklas.id;
                  email = lldapUsers.niklas.email;
                  dbLocation = "${config.nps.storageBaseDir}/storyteller/storyteller.db";
                };
              }
            ))
          ];
        };
      };

      streaming =
        {
          gluetun = {
            vpnProvider = "airvpn";
            wireguardPrivateKeyFile = config.sops.secrets."gluetun/wg_pk".path;
            wireguardPresharedKeyFile = config.sops.secrets."gluetun/wg_psk".path;
            wireguardAddressesFile = config.sops.secrets."gluetun/wg_address".path;

            extraEnv = {
              FIREWALL_VPN_INPUT_PORTS.fromFile = config.sops.secrets."qbittorrent/torrenting_port".path;
              SERVER_NAMES.fromFile = config.sops.secrets."gluetun/server_names".path;
              HTTP_CONTROL_SERVER_LOG = "off";
            };
          };
          containers.gluetun.ports = ["8888:8888"];
          qbittorrent.extraEnv = {
            TORRENTING_PORT.fromFile = config.sops.secrets."qbittorrent/torrenting_port".path;
          };
          jellyfin = {
            oidc = {
              enable = true;
              clientSecretFile = config.sops.secrets."jellyfin/authelia/client_secret".path;
            };
          };
          qui = {
            enable = true;
            oidc = {
              enable = true;
              clientSecretFile = config.sops.secrets."qui/authelia/client_secret".path;
            };
          };
        }
        // lib.genAttrs ["sonarr" "radarr" "bazarr" "prowlarr"] (name: {
          extraEnv."${lib.toUpper name}__AUTH__APIKEY".fromFile = config.sops.secrets."servarr/api_key".path;
        });

      tandoor = {
        secretKeyFile = config.sops.secrets."tandoor/secret_key".path;
        db.passwordFile = config.sops.secrets."tandoor/db_password".path;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."tandoor/authelia/client_secret".path;
        };
        containers.tandoor.extraEnv = {
          # https://docs.tandoor.dev/system/configuration/#default-permissions
          SOCIAL_DEFAULT_ACCESS = 1;
          SOCIAL_DEFAULT_GROUP = "user";
        };
      };

      timetracker = {
        secretKeyFile = config.sops.secrets."timetracker/secret_key".path;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."timetracker/authelia/client_secret".path;
        };
        db.passwordFile = config.sops.secrets."timetracker/db_password".path;
        containers.timetracker.extraEnv = {
          #AUTH_METHOD = "oidc";
          ALLOW_SELF_REGISTER = false;
        };
      };

      traefik = {
        domain = domain;
        extraEnv.CF_DNS_API_TOKEN.fromFile = config.sops.secrets."CLOUDFLARE_API_KEY".path;
        geoblock.allowedCountries = ["DE"];
        enablePrometheusExport = true;
        enableGrafanaMetricsDashboard = true;
        enableGrafanaAccessLogDashboard = true;
        crowdsec.middleware.bouncerKeyFile = config.sops.secrets."crowdsec/traefik_bouncer_key".path;
        containers.traefik.extraConfig.Container.DNS = "1.1.1.1";
      };

      vaultwarden = {
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."vaultwarden/authelia/client_secret".path;
        };
        extraEnv = {
          SIGNUPS_ALLOWED = false;
          SSO_ONLY = true;
        };
      };

      vikunja = {
        db.type = "postgres";
        db.passwordFile = config.sops.secrets."vikunja/postgres_password".path;
        jwtSecretFile = config.sops.secrets."vikunja/jwt_secret".path;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."vikunja/authelia/client_secret".path;
        };
        settings = {
          service.enableregistration = false;
          auth.local.enabled = false;
        };
      };

      webtop = {
        containers.webtop = {
          devices = ["/dev/dri/renderD128:/dev/dri/renderD128"];
          environment.DRINODE = "/dev/dri/renderD128";
        };
      };

      wg-easy = {
        adminPasswordFile = config.sops.secrets."wg-easy/init_password".path;
        extraEnv = {
          DISABLE_IPV6 = true;
        };
      };
      wg-portal = {
        port = 51825;
        settings.core = {
          admin_user = "admin";
          admin_password = "\${ADMIN_PASSWORD}";
        };
        extraEnv.ADMIN_PASSWORD.fromFile = config.sops.secrets."wg-portal/admin_password".path;
        settings.advanved.use_ip_v6 = false;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."wg-portal/authelia/client_secret".path;
        };
      };
    };
  };
}
