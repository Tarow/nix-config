# Configure stacks that require configuration.
# Stacks are only configured here, but enabled in each hosts configuration.
{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [inputs.nix-podman-stacks.homeModules.nps];

  # Add default config to every container
  options.services.podman.containers = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        extraConfig.Unit = {
          Wants = ["sops-nix.service"];
          After = ["sops-nix.service"];
        };
      }
    );
  };

  config.nps = rec {
    hostIP4Address = config.tarow.facts.ip4Address;
    hostUid = config.tarow.facts.uid;
    defaultTz = "Europe/Berlin";

    stacks = {
      aiostreams = {
        extraEnv = {
          SECRET_KEY.fromFile = config.sops.secrets."aiostreams/secret_key".path;
          TMDB_ACCESS_TOKEN.fromFile = config.sops.secrets."aiostreams/tmdb_access_token".path;
          DEFAULT_REALDEBRID_API_KEY.fromFile = config.sops.secrets."aiostreams/rd_api_key".path;
        };
      };
      authelia = {
        jwtSecretFile = config.sops.secrets."authelia/jwt_secret".path;
        sessionSecretFile = config.sops.secrets."authelia/session_secret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/encryption_key".path;
        authenticationBackend.type = "ldap";
        oidc = {
          enable = true;
          hmacSecretFile = config.sops.secrets."authelia/oidc_hmac_secret".path;
          jwksRsaKeyFile = config.sops.secrets."authelia/oidc_rsa_pk".path;

          # Define a dummy client with two_factor to enable the related settings
          #
          clients.dummy = {
            public = true;
            authorization_policy = "two_factor";
            redirect_uris = [];
          };
        };
      };

      beszel = {
        ed25519PrivateKeyFile = config.sops.secrets."beszel/ssh_key".path;
        ed25519PublicKeyFile = config.sops.secrets."beszel/ssh_pub_key".path;
        oidc = {
          registerClient = true;
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$iTcxhF8YJvibvv9jyHKPsg$+srgYmZS5vXMyLmkyGZbaP2yC3ILohBXmJ1wXtAMOl0";
        };
      };
      blocky = {
        enableGrafanaDashboard = true;
        enablePrometheusExport = true;
        containers.blocky = {
          homepage.settings.href = "${config.nps.containers.grafana.traefik.serviceUrl}/d/blocky";
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
      bytestash = {
        extraEnv.JWT_SECRET.fromFile = config.sops.secrets."bytestash/jwt_secret".path;
      };
      crowdsec = {
        extraEnv = {
          ENROLL_INSTANCE_NAME = "homeserver";
          ENROLL_KEY.fromFile = config.sops.secrets."crowdsec/enroll_key".path;
        };
        traefikIntegration = {
          bouncerKeyFile = config.sops.secrets."crowdsec/traefik_bouncer_key".path;
        };
      };
      dockdns = {
        extraEnv.NTASLER_DE_API_TOKEN.fromFile = config.sops.secrets."dockdns/cf_api_token".path;
        settings.dns.purgeUnknown = true;
        settings.domains = let
          domain = config.nps.stacks.traefik.domain or "";
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
      freshrss = {
        adminProvisioning = {
          enable = true;
          username = "admin";
          email = "admin@example.com";
          passwordFile = config.sops.secrets."freshrss/admin_password".path;
          apiPasswordFile = config.sops.secrets."freshrss/admin_api_password".path;
        };
      };
      gatus = {
        db = {
          type = "postgres";
          postgresPasswordFile = config.sops.secrets."gatus/postgresPassword".path;
        };

        oidc = {
          allowedSubjects = [];
          enable = true;
          clientSecretFile = config.sops.secrets."gatus/authelia_client_secret".path;
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$4wovJBwfMgWMqeV9S4HZyg$HcnArT/vCP2e4N6tgNYWXwYj73cointfSM4ITOXKmzQ";
        };
      };
      healthchecks = {
        secretKeyFile = config.sops.secrets."healthchecks/secret_key".path;
        superUserEmail = stacks.lldap.bootstrap.users.niklas.email;
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
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."immich/authelia/client_secret".path;
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$18FxDTnTEcrx4PFl8fHjhQ$Iv09KL9IJAMfHWIhPDr1f3kVf/D/BUyoPPQTEhGBPNM";
        };
        dbPasswordFile = config.sops.secrets."immich/db_password".path;
      };

      karakeep = {
        oidc = {
          enable = true;
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$j1iaujV4SedP9TISGPon4w$EY+mQ3fH8C74+PrGw3TrGQRvKzCCjthYV43Hqrs31tk";
          clientSecretFile = config.sops.secrets."karakeep/authelia/client_secret".path;
        };
        nextauthSecretFile = config.sops.secrets."karakeep/nextauth_secret".path;
        meiliMasterKeyFile = config.sops.secrets."karakeep/meili_master_key".path;
      };

      kimai = {
        adminEmail = "admin@admin.com";
        adminPasswordFile = config.sops.secrets."kimai/admin_password".path;
        db = {
          databaseName = "kimai";
          username = "kimai";
          userPasswordFile = config.sops.secrets."kimai/db_user_password".path;
          rootPasswordFile = config.sops.secrets."kimai/db_root_password".path;
        };
      };

      lldap = {
        baseDn = "DC=ntasler,DC=de";
        jwtSecretFile = config.sops.secrets."lldap/jwtSecret".path;
        keySeedFile = config.sops.secrets."lldap/keySeed".path;
        adminPasswordFile = config.sops.secrets."lldap/adminPassword".path;
        bootstrap = {
          cleanUp = true;
          users = {
            niklas = {
              email = "niklas@${stacks.traefik.domain}";
              password_file = config.sops.secrets."lldap/niklas_password".path;
              displayName = "Niklas";
              groups = [
                "grafana_admin"
                "immich_admin"
                "jellyfin_admin"
                "lldap_admin"
                "mealie_admin"
                "wg_portal_admin"
              ];
            };
            selma = {
              email = "selma@${stacks.traefik.domain}";
              password_file = config.sops.secrets."lldap/selma_password".path;
              displayName = "Selma";
              groups = [
                "jellyfin_user"
                "mealie_user"
              ];
            };
          };
        };
      };

      mealie = {
        oidc = {
          enable = true;
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$i7b124sTgqymSkCBnsZ0Qw$tDCVnQC1Kn191ygs2Rao7pCne3RNDnEYf7c1d11uBx0";
          clientSecretFile = config.sops.secrets."mealie/authelia/client_secret".path;
        };
      };

      microbin = {
        extraEnv = {
          MICROBIN_ADMIN_USERNAME = "admin";
          MICROBIN_ADMIN_PASSWORD.fromFile = config.sops.secrets."microbin/admin_password".path;
          MICROBIN_UPLOADER_PASSWORD.fromFile = config.sops.secrets."microbin/uploader_password".path;
        };
      };

      monitoring.grafana = {
        oidc = {
          enable = true;
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$7/u7j+Jk0uexxJ4CaylQWw$t2EQJPYklJFqr6+MqJg7uCgmZaYaH+KgEtOpEGdQta8";
          clientSecretFile = config.sops.secrets."grafana/authelia/client_secret".path;
        };
      };

      ntfy = {
        extraEnv = {
          NTFY_WEB_PUSH_EMAIL_ADDRESS = "admin@ntasler.de";
          NTFY_WEB_PUSH_PUBLIC_KEY.fromFile = config.sops.secrets."ntfy/web_push_public_key".path;
          NTFY_WEB_PUSH_PRIVATE_KEY.fromFile = config.sops.secrets."ntfy/web_push_private_key".path;
        };
        enableGrafanaDashboard = true;
        enablePrometheusExport = true;
      };
      paperless = {
        adminProvisioning = {
          username = "admin";
          passwordFile = config.sops.secrets."paperless/admin_password".path;
          email = "admin@example.com";
        };
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."paperless/authelia_client_secret".path;
          clientSecretHash = "$pbkdf2-sha512$310000$0IgF7vx.fWICGnbGGMQosw$v73kGV4a5sBX2Zc39aS.vLj..IepDX02NK.xsAYpUaAvXdIr65BYU6TnAmPiusjyaa.sCiF6vrmoEgWyWpr/SQ";
        };
        secretKeyFile = config.sops.secrets."paperless/secret_key".path;
        extraEnv = {
          PAPERLESS_OCR_LANGUAGES = "eng deu";
          PAPERLESS_OCR_LANGUAGE = "eng+deu";
        };
        db = {
          username = "paperless";
          passwordFile = config.sops.secrets."paperless/db_password".path;
        };
        ftp = {
          enable = true;
          passwordFile = config.sops.secrets."paperless/ftp_password".path;
        };
      };
      pocketid = {
        traefikIntegration = {
          enable = true;
          clientId = "8c55dd45-1c75-4e01-bdd1-300af3eadcc7";
          clientSecretFile = config.sops.secrets."pocketid/traefik/clientSecret".path;
          encryptionSecretFile = config.sops.secrets."pocketid/traefik/middlewareSecret".path;
        };
      };
      romm = {
        adminProvisioning = {
          enable = true;
          username = "admin";
          passwordFile = config.sops.secrets."romm/admin_password".path;
          email = "admin@example.com";
        };

        authSecretKeyFile = config.sops.secrets."romm/auth_secret_key".path;
        romLibraryPath = "${config.nps.externalStorageBaseDir}/romm/library";
        extraEnv = {
          IGDB_CLIENT_ID.fromFile = config.sops.secrets."romm/igdb_client_id".path;
          IGDB_CLIENT_SECRET.fromFile = config.sops.secrets."romm/igdb_client_secret".path;
        };

        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."romm/authelia/client_secret".path;
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$pki2TtHTQZnqLA+j+yPuzg$7KOitH9Co3DLmb4bVNoepg2PHARG2VNCAywieLwt9SE";
        };

        db = {
          userPasswordFile = config.sops.secrets."romm/db/user_password".path;
          rootPasswordFile = config.sops.secrets."romm/db/root_password".path;
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
          qbittorrent.extraEnv = {
            TORRENTING_PORT.fromFile = config.sops.secrets."qbittorrent/torrenting_port".path;
          };
          jellyfin = {
            oidc = {
              enable = true;
              clientSecretFile = config.sops.secrets."jellyfin/authelia/client_secret".path;
              clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$bvFrDVncsSd6rRIsqwXTRA$epymT2YwTSB5PDByAp7mXGdrQ/N+aEEMOzXaWvQ5xUM";
            };
          };
        }
        // lib.genAttrs ["sonarr" "radarr" "bazarr" "prowlarr"] (name: {
          extraEnv."${lib.toUpper name}__AUTH__APIKEY".fromFile = config.sops.secrets."servarr/api_key".path;
        });
      traefik = {
        domain = "ntasler.de";
        extraEnv.CF_DNS_API_TOKEN.fromFile = config.sops.secrets."traefik/cf_api_token".path;
        geoblock.allowedCountries = ["DE"];
        enablePrometheusExport = true;
        enableGrafanaMetricsDashboard = true;
        enableGrafanaAccessLogDashboard = true;
      };

      wg-easy = {
        extraEnv = {
          INIT_PASSWORD.fromFile = config.sops.secrets."wg-easy/init_password".path;
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
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$OMvEmtEjIUjfRqW2FkZiQg$GAKvd0HJ8f8AE3F6LpBptew/PFcEchXfERhhf73IgnI";
        };
      };
    };
  };
}
