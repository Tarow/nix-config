{
  tls = {
    options = {
      default = {
        sniStrict = true;
        minVersion = "VersionTLS12";
        cipherSuites = ["TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256" "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384" "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305" "TLS_AES_128_GCM_SHA256" "TLS_AES_256_GCM_SHA384" "TLS_CHACHA20_POLY1305_SHA256"];
        curvePreferences = ["CurveP521" "CurveP384"];
      };
    };
  };
  http = {
    middlewares = {
      public-chain.chain.middlewares = ["public-ratelimit" "security-headers" "geoblock" "crowdsec"];
      private-chain.chain.middlewares = ["ipwhitelist-internal"];
      ipwhitelist-internal.ipAllowList.sourceRange = ["10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"];
      public-ratelimit.rateLimit = {
        average = 100;
        burst = 100;
      };

      geoblock.plugin.geoblock = {
        enabled = true;
        databaseFilePath = "/plugins/geoblock/IP2LOCATION-LITE-DB1.IPV6.BIN";
        allowedCountries = ["DE"];
        allowPrivate = true;
        disallowedStatusCode = 403;
      };

      crowdsec.plugin.bouncer = {
        enabled = true;
        logLevel = "INFO";
        updateIntervalSeconds = 60;
        updateMaxFailure = 0;
        defaultDecisionSeconds = 60;
        httpTimeoutSeconds = 10;
        crowdsecMode = "live";
        crowdsecAppsecEnabled = false;
        crowdsecAppsecHost = "crowdsec:7422";
        crowdsecAppsecPath = "/";
        crowdsecAppsecFailureBlock = true;
        crowdsecAppsecUnreachableBlock = true;
        crowdsecAppsecBodyLimit = 10485760;
        crowdsecLapiKey = "{{ env \"BOUNCER_KEY_TRAEFIK\" }}";
        crowdsecLapiScheme = "http";
        crowdsecLapiHost = "crowdsec:8080";
        crowdsecLapiPath = "/";
        clientTrustedIPs = ["10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16"];
      };

      security-headers.headers = {
        hostsProxyHeaders = ["X-Forwarded-Host"];
        stsSeconds = 63072000;
        stsIncludeSubdomains = true;
        stsPreload = true;
        forceSTSHeader = true;
        customFrameOptionsValue = "SAMEORIGIN";
        browserXssFilter = true;
        referrerPolicy = "same-origin";
        permissionsPolicy = "camera=(), microphone=(), geolocation=(), payment=(), usb=(), vr=()";
        customResponseHeaders = {
          X-Robots-Tag = "none,noarchive,nosnippet,notranslate,noimageindex,";
          server = "";
        };
      };
    };
  };
}
