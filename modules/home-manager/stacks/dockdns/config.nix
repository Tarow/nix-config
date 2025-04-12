config: let
  domain = config.tarow.stacks.traefik.domain;
  ip = config.tarow.facts.ip4Address;
in ''
  interval: 300
  debounceTime: 10
  maxDebounceTime: 600

  webUI: true

  log:
    level: debug

  zones:
    - name: ${domain}
      provider: cloudflare
      apiToken: ${config.sops.placeholder."dockdns/apiToken"}
      zoneID: ${config.sops.placeholder."dockdns/zoneID"}

  dns:
    a: true
    aaaa: false
    defaultTTL: 300
    purgeUnknown: true

  domains:
    - name: "${domain}"
      a: ${ip}

    - name: "*.${domain}"
      a: ${ip}

    - name: "vpn.${domain}"
''
