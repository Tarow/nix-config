{config, ...}: {
  nps = let
    domain = "relsat.de";
    lldapUsers = {
      readonly = {
        id = "readonly";
        displayName = "readonly";
        password_file = config.sops.secrets."lldap/readonly_password".path;
        email = "readonly@${domain}";
        groups = [config.nps.stacks.lldap.readOnlyGroup];
      };
    };
  in {
    hostIP4Address = config.tarow.facts.ip4Address;
    hostUid = 1000;
    storageBaseDir = "${config.home.homeDirectory}/stacks";
    externalStorageBaseDir = "/mnt/hdd1";

    stacks = {
      authelia = {
        enable = true;
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
        };
        sessionProvider = "redis";
      };

      booklore = {
        enable = true;
        oidc = {
          registerClient = true;
        };
        db = {
          userPasswordFile = config.sops.secrets."booklore/db_user_password".path;
          rootPasswordFile = config.sops.secrets."booklore/db_root_password".path;
        };
      };

      ephemera = {
        enable = true;
        downloadDirectory = "${config.nps.storageBaseDir}/booklore/bookdrop";
      };

      immich = {
        enable = true;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."immich/authelia/client_secret".path;
          clientSecretHash = "$pbkdf2-sha512$310000$l8pHo5lLbManfxNCLP3gTQ$.o9bL6ol7SUf7X4dvlCaPPsgBgEk2jelCutnUXtG9nCVK7EU2KIUe0NcyPmpVP0EBUW.A8Sj1LIq4ngJm.f0Aw";
        };
        db.passwordFile = config.sops.secrets."immich/db_password".path;
        settings = {
          oauth.autoLaunch = true;
          passwordLogin.enabled = false;
        };

        containers.immich.volumes = [
          "${config.nps.externalStorageBaseDir}/shares/hermann/Fotos:/mnt/hdd/fotos:ro"
        ];
      };

      lldap = {
        enable = true;
        baseDn = "DC=relsat,DC=de";
        jwtSecretFile = config.sops.secrets."lldap/jwtSecret".path;
        keySeedFile = config.sops.secrets."lldap/keySeed".path;
        adminPasswordFile = config.sops.secrets."lldap/adminPassword".path;
        bootstrap.users = lldapUsers;
      };

      blocky.enable = true;

      dockdns = {
        enable = true;
        extraEnv.RELSAT_DE_API_TOKEN.fromFile = config.sops.secrets."CLOUDFLARE_API_KEY".path;
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

      docker-socket-proxy.enable = true;
      homepage.enable = true;
      mazanoke.enable = true;
      monitoring.enable = true;

      norish = {
        enable = true;
        masterKeyFile = config.sops.secrets."norish/master_key".path;
        db.passwordFile = config.sops.secrets."norish/db_password".path;
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."norish/authelia/client_secret".path;
          clientSecretHash = "$pbkdf2-sha512$310000$iCUXG7YDbRaMGNrucrPjyw$ZUIAIlt6DDzFfFFf6xnU6FeS/fj9fGoTnII9bcUpMVwhnxU8gQskO01StyVIp.HHAZpN4poVkR/lFf1i7pBk2A";
        };
      };

      paperless = {
        enable = true;
        enableTika = true;
        adminProvisioning = {
          username = "niklas";
          passwordFile = config.sops.secrets."users/niklas/password".path;
          email = "niklas@${domain}";
        };
        oidc = {
          enable = true;
          clientSecretFile = config.sops.secrets."paperless/authelia/client_secret".path;
          clientSecretHash = "$pbkdf2-sha512$310000$Yfb9s6emwWSI1kepQSmhUQ$tZiLJlDZKByzc0tMm5wWQIWnaSLCE0b4RJ9k0bbI7s3JGjOQ4mRsHbcBlCqF2J3FibZv0GLL4RON9ALwMSAC3g";
        };
        secretKeyFile = config.sops.secrets."paperless/secret_key".path;
        extraEnv = {
          PAPERLESS_OCR_LANGUAGES = "eng deu";
          PAPERLESS_OCR_LANGUAGE = "eng+deu";
          PAPERLESS_DISABLE_REGULAR_LOGIN = true;
          PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
          PAPERLESS_CONSUMER_RECURSIVE = true;
        };
        db = {
          passwordFile = config.sops.secrets."paperless/db_password".path;
        };

        containers.paperless = {
          environment.PAPERLESS_CONSUMPTION_DIR = "/consume";
          volumes = ["${config.nps.externalStorageBaseDir}/shares/paperless_consume:/consume"];
        };
      };

      traefik = {
        enable = true;
        domain = domain;
        geoblock.allowedCountries = ["DE"];
        enablePrometheusExport = true;
        enableGrafanaMetricsDashboard = true;
        enableGrafanaAccessLogDashboard = true;

        extraEnv.CF_DNS_API_TOKEN.fromFile = config.sops.secrets."CLOUDFLARE_API_KEY".path;
      };
    };
  };
}
