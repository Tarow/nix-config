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

        # No group-based admin access supported yet, just user-roles
        karakeep.oidc.userGroup
        romm.oidc.userGroup
        paperless.oidc.userGroup
        gatus.oidc.userGroup
        vikunja.oidc.userGroup
        freshrss.oidc.userGroup
        outline.oidc.userGroup
        storyteller.oidc.userGroup
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
      ];
    };
  };
in {
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

  config.nps = {
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
      audiobookshelf = {
        oidc = {
          registerClient = true;
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$dQHFMSR+Fhdx84GamLJ5LA$jzJevY6G+J9tClLxIAqozoPOeytSduR0v1HMAFR++ko";
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

        containers.authelia = {
          traefik.subDomain = "auth";
          expose = true;
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
        extraEnv.NTASLER_DE_API_TOKEN.fromFile = config.sops.secrets."dockdns/cf_api_token".path;
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
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$elNsvcPnuBeCRSPPVdTmtg$thuONNyx0kGKQhtSJwOqwCzWVrQ5yTu899MIrgEDkIA";
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
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$SKzEY6iUGM8T5jpdjBt/qg$Eipoepsk2j0Dxp/DDdoj/ZcmRbkf3FLnjgr4oP2xZ2s";
          clientSecretFile = config.sops.secrets."filebrowser-quantum/authelia/client_secret".path;
        };
        settings.auth.methods.password.enabled = false;
      };
      freshrss = {
        # First OIDC-logged-in account will have admin rights
        # See <https://freshrss.github.io/FreshRSS/en/admins/16_OpenID-Connect.html> for setup
        oidc = {
          enable = true;
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$W0jLoTPPDwal2PULWcmlSg$HtzE9xiR+5lHFO8eRqlI27+lqLYWPbqSybyyiaL/y8s";
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
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$4wovJBwfMgWMqeV9S4HZyg$HcnArT/vCP2e4N6tgNYWXwYj73cointfSM4ITOXKmzQ";
        };
        containers.gatus.environment.GATUS_LOG_LEVEL = "DEBUG";

        settings.endpoints = let
          # Check that all exposed services are reachable via the public IP
          exposedContainers = config.services.podman.containers |> lib.filterAttrs (_: c: c.expose);
          exposedEndpointChecks =
            exposedContainers
            |> lib.mapAttrs (name: c: {
              url = c.traefik.serviceUrl;
              name = "${lib.toSentenceCase name} External";
              client.dns-resolver = "tcp://1.1.1.1:53";
              group = "ext_availability";

              headers.Accept = "text/html";
            })
            |> lib.attrValues;
        in
          exposedEndpointChecks
          ++ [
            {
              name = "External IP";
              url = "icmp://vpn.${domain}";
              client.dns-resolver = "tcp://1.1.1.1:53";
              group = "ext_availability";
              conditions = [
                "[CONNECTED] == true"
              ];
            }
          ];
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
          templateMount = [
            {
              templatePath = pkgs.writeText "user-mapping.xml" ''
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
              destPath = "/etc/guacamole/user-mapping.xml";
            }
          ];
        };
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
        settings = {
          oauth.autoLaunch = lib.mkForce true;
          passwordLogin.enabled = lib.mkForce false;
        };
      };

      karakeep = {
        oidc = {
          enable = true;
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$j1iaujV4SedP9TISGPon4w$EY+mQ3fH8C74+PrGw3TrGQRvKzCCjthYV43Hqrs31tk";
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
          clientSecretHash = "$pbkdf2-sha512$310000$Hza0NJjEkCNvMl5Z0Yn8QQ$Y/d.qKdU9igqRtkQZ3IFc5r.D4i9MG6VgF9/JwbXFu8cGMbLeQCo644vY7LPm3CZe1G0HRxrpqlbqcsncraYEA";
        };
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
          PAPERLESS_DISABLE_REGULAR_LOGIN = true;
          PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
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
        ldap = {
          username = lldapUsers.readonly.id;
          passwordFile = lldapUsers.readonly.password_file;
        };
      };
      romm = {
        adminProvisioning = {
          enable = true;
          username = lldapUsers.niklas.id;
          passwordFile = lldapUsers.niklas.password_file;
          email = lldapUsers.niklas.email;
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
          clientSecretHash = "$pbkdf2-sha512$310000$lRGcfTq0UOnzsyWOf4WCYw$R1jpZLd0sUh.SRVnLuFJDDURwyCXGnomxioKc8xSXkkFO3IvFpiT5xIE25wRyKdQlqGKSxfNqPG.nJWWNtJPsw";
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
        domain = domain;
        extraEnv.CF_DNS_API_TOKEN.fromFile = config.sops.secrets."traefik/cf_api_token".path;
        geoblock.allowedCountries = ["DE"];
        enablePrometheusExport = true;
        enableGrafanaMetricsDashboard = true;
        enableGrafanaAccessLogDashboard = true;
        crowdsec.middleware.bouncerKeyFile = config.sops.secrets."crowdsec/traefik_bouncer_key".path;
      };

      vikunja = {
        db.type = "postgres";
        db.passwordFile = config.sops.secrets."vikunja/postgres_password".path;
        jwtSecretFile = config.sops.secrets."vikunja/jwt_secret".path;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."vikunja/authelia/client_secret".path;
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$5yan15Eue1VX6WsFW5LygA$//p0a4BWfLJKt4BMmagCF9HgokO5bIO6se99XmFHhA8";
        };
        settings = {
          service.enableregistration = false;
          auth.local.enabled = false;
        };
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
