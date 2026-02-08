{
  lib,
  config,
  pkgs,
  ...
}: {
  nps = {
    hostIP4Address = "10.1.1.148";
    hostUid = 1000;
    storageBaseDir = "${config.home.homeDirectory}/stacks";
    externalStorageBaseDir = "/mnt/hdd1";

    stacks = {
      authelia = {
        enable = true;
        jwtSecretFile = config.sops.secrets."authelia/jwt_secret".path;
        sessionSecretFile = config.sops.secrets."authelia/session_secret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/encryption_key".path;

        oidc = {
          enable = true;
          hmacSecretFile = config.sops.secrets."authelia/oidc_hmac_secret".path;
          jwksRsaKeyFile = config.sops.secrets."authelia/oidc_rsa_pk".path;

          # Define a dummy client with two_factor to enable the related settings
        };
        sessionProvider = "redis";
      };
      lldap = {
        enable = true;
        baseDn = "DC=ntasler,DC=de";
        jwtSecretFile = config.sops.secrets."lldap/jwtSecret".path;
        keySeedFile = config.sops.secrets."lldap/keySeed".path;
        adminPasswordFile = config.sops.secrets."lldap/adminPassword".path;
      };
      freshrss = {
        enable = false;
        # First OIDC-logged-in account will have admin rights
        # See <https://freshrss.github.io/FreshRSS/en/admins/16_OpenID-Connect.html> for setup
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."freshrss/authelia/client_secret".path;
          cryptoKeyFile = config.sops.secrets."freshrss/authelia/crypto_key".path;
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

      outline = {
        enable = true;
        secretKeyFile = config.sops.secrets."outline/secret_key".path;
        utilsSecretFile = config.sops.secrets."outline/utils_secret".path;
        db.passwordFile = config.sops.secrets."outline/db_password".path;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."outline/authelia/client_secret".path;
        };
        containers.outline.extraConfig.Container.DNS = "100.100.100.100";
      };

      romm = {
        enable = true;
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
        containers.romm.volumeMap.assets = lib.mkForce "${config.home.homeDirectory}/tmp/romm/testassets:/romm/assets";
      };

      blocky.enable = true;
      dozzle.enable = true;
      docker-socket-proxy.enable = true;
      homepage.enable = true;
      monitoring.enable = true;
      glance.enable = true;
      glance.containers.glance.traefik.subDomain = "glance";
      #monitoring.containers.alloy.reverseProxy.serviceName = lib.mkForce "logs";

      /*
        tsbridge = {
        enable = true;
        tailnetDomain = "taimen-manta.ts.net";
        defaultTags = ["tag:desktop"];
        oauth = {
          clientId = "ktMTxmGi6N11CNTRL";
          clientSecretFile = config.sops.secrets."tsbridge/oauth_client_secret".path;
        };
      };
      */

      leantime = {
        enable = true;
        sessionPasswordFile = config.sops.secrets."leantime/session_password".path;
        db = {
          userPasswordFile = config.sops.secrets."leantime/db_user_password".path;
          rootPasswordFile = config.sops.secrets."leantime/db_root_password".path;
        };
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."leantime/authelia/client_secret".path;
        };
      };

      n8n.enable = true;
      traefik = {
        enable = true;
        domain = "testing.ntasler.de";
        geoblock.allowedCountries = ["DE"];
        enablePrometheusExport = true;
        enableGrafanaMetricsDashboard = true;
        enableGrafanaAccessLogDashboard = true;

        extraEnv.CF_DNS_API_TOKEN.fromFile = config.sops.secrets."CLOUDFLARE_API_KEY".path;

        dynamicConfig = {
          http.middlewares = {
            ipwhitelist-internal = {
              ipAllowList.sourceRange = [
                "10.0.0.0/8"
                "172.16.0.0/12"
                "192.168.0.0/16"
                "100.64.0.0/10" # Tailscale CGNAT range
              ];
            };
          };
        };
      };
    };
  };
}
