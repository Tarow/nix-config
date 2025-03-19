domain: ''
  api:
    insecure: true
    dashboard: true

  providers:
    http:
      endpoint: "http://pangolin:3001/api/v1/traefik-config"
      pollInterval: "5s"
    file:
      filename: "/etc/traefik/dynamic_config.yml"

  experimental:
    plugins:
      badger:
        moduleName: "github.com/fosrl/badger"
        version: "v1.0.0"

  log:
    level: "INFO"
    format: "common"

  certificatesResolvers:
    letsencrypt:
      acme:
        dnsChallenge:
          provider: cloudflare
        email: "admin@${domain}"
        storage: "/letsencrypt/acme.json"
        caServer: "https://acme-v02.api.letsencrypt.org/directory"

  entryPoints:
    web:
      address: ":80"
    websecure:
      address: ":443"
      transport:
        respondingTimeouts:
          readTimeout: "30m"

      http:
        tls:
          certResolver: letsencrypt
          domains:
            - main: ${domain}
              sans:
                - "*.${domain}"

  serversTransport:
    insecureSkipVerify: true
''
