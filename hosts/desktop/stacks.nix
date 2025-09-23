{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    {
      nixpkgs.overlays = [
        (final: prev: {
          sd-switch = pkgs.unstable.sd-switch;
        })
      ];
    }
  ];

  home.file."version.txt".text = config.home.version.release;

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
        containers.authelia = {
          traefik.subDomain = "auth";
          expose = true;
        };
      };
      lldap = {
        enable = true;
        baseDn = "DC=ntasler,DC=de";
        jwtSecretFile = config.sops.secrets."lldap/jwtSecret".path;
        keySeedFile = config.sops.secrets."lldap/keySeed".path;
        adminPasswordFile = config.sops.secrets."lldap/adminPassword".path;
      };
      freshrss = {
        enable = true;
        adminProvisioning = {
          enable = true;
          username = "admin";
          email = "admin@example.com";
          passwordFile = pkgs.writeText "p" "password";
          apiPasswordFile = pkgs.writeText "p" "password";
        };
        # First OIDC-logged-in account will have admin rights
        # See <https://freshrss.github.io/FreshRSS/en/admins/16_OpenID-Connect.html> for setup
        oidc = {
          enable = true;
          clientSecretHash = "$argon2id$v=19$m=65536,t=3,p=4$W0jLoTPPDwal2PULWcmlSg$HtzE9xiR+5lHFO8eRqlI27+lqLYWPbqSybyyiaL/y8s";
          clientSecretFile = config.sops.secrets."freshrss/authelia/client_secret".path;
          cryptoKeyFile = config.sops.secrets."freshrss/authelia/crypto_key".path;
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
          clientSecretHash = "$pbkdf2-sha512$310000$NZWRZbYxrmbsOG12AGE2eA$3ZZoqHOxpWciUaB3U0Zc14lMigmXFtkEH5r2yRMWuHlRqM2Go3Z7C0grzbQD6Gy9RtnpctNJrcb1fWuQ4uMOHA";
        };
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

      blocky.enable = true;
      docker-socket-proxy.enable = true;
      homepage.enable = true;
      monitoring.enable = true;

      traefik = {
        enable = true;
        domain = "testing.ntasler.de";
        geoblock.allowedCountries = ["DE"];
        enablePrometheusExport = true;
        enableGrafanaMetricsDashboard = true;
        enableGrafanaAccessLogDashboard = true;

        extraEnv.CF_DNS_API_TOKEN.fromFile = config.sops.secrets."traefik/cf_api_token".path;

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
