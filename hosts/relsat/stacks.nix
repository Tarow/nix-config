{
  lib,
  config,
  pkgs,
  ...
}: {
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
      lldap = {
        enable = true;
        baseDn = "DC=relsat,DC=de";
        jwtSecretFile = config.sops.secrets."lldap/jwtSecret".path;
        keySeedFile = config.sops.secrets."lldap/keySeed".path;
        adminPasswordFile = config.sops.secrets."lldap/adminPassword".path;
      };

      blocky.enable = true;
      docker-socket-proxy.enable = true;
      homepage.enable = true;
      monitoring.enable = true;

      traefik = {
        enable = true;
        domain = "relsat.de";
        geoblock.allowedCountries = ["DE"];
        enablePrometheusExport = true;
        enableGrafanaMetricsDashboard = true;
        enableGrafanaAccessLogDashboard = true;

        extraEnv.CF_DNS_API_TOKEN.fromFile = config.sops.secrets."CLOUDFLARE_API_KEY".path;
      };
    };
  };
}
