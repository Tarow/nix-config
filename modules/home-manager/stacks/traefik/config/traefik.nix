{domain}: ''
  entryPoints:
    web:
      address: ":80"
      http:
        redirections:
          entryPoint:
            to: websecure
            scheme: https
    websecure:
      address: ":443"
      http:
        tls:
          certResolver: letsencrypt
          domains:
            - main: ${domain}
              sans:
                - "*.${domain}"

  serversTransport:
    insecureSkipVerify: true

  api:
    dashboard: true

  providers:
    docker:
      exposedByDefault: false
      network: traefik-proxy
      defaultRule: Host(`{{ coalesce (index .Labels "com.docker.compose.service") (normalize .Name) }}.${domain}`)
    file:
      directory: /dynamic
      watch: true

  certificatesResolvers:
    letsencrypt:
      acme:
        email: mail@${domain}
        storage: /letsencrypt/acme.json
        dnsChallenge:
          provider: cloudflare
          resolvers:
            - 1.1.1.1:53
            - 8.8.8.8:53

  experimental:
    plugins:
      geoblock:
        moduleName: github.com/nscuro/traefik-plugin-geoblock
        version: v0.14.0
      bouncer:
        moduleName: github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin
        version: v1.4.2
      sablier:
        moduleName: "github.com/sablierapp/sablier"
        version: "v1.8.5"

  accessLog:
    format: json

  log:
    level: WARN
''
