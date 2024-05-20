{ config, vars, lib, ... }:

let
  name = "crowdsec";
in
{
  options = {
    docker.${name}.enable = lib.mkEnableOption name;
  };

  config = lib.mkIf config.docker.${name}.enable {
    home.file."docker/${name}/compose.yaml".text =
      ''
        services:
          crowdsec:
            image: crowdsecurity/crowdsec:latest
            container_name: crowdsec
            restart: unless-stopped
            environment:
              GID: 1000
              PUID: 1000
              PGID: 1000
              COLLECTIONS: "crowdsecurity/traefik crowdsecurity/http-cve crowdsecurity/whitelist-good-actors LePresidente/authelia"
            networks:
              - traefik-proxy # In order to reach ntfy for notifications
            volumes:
              - ./data:/var/lib/crowdsec/data
              - ./config:/etc/crowdsec
              - ./acquis.yaml:/etc/crowdsec/acquis.yaml
              - ./http-ntfy.yaml:/etc/crowdsec/notifications/http.yaml
              - '/var/run/docker.sock:/var/run/docker.sock:ro'
              - './immich-whitelist.yaml:/etc/crowdsec/parsers/s02-enrich/immich-whitelist.yaml'

          bouncer-traefik:
            image: docker.io/fbonalair/traefik-crowdsec-bouncer:latest
            container_name: bouncer-traefik
            restart: unless-stopped
            env_file:
              - bouncer-traefik.env
            environment:
              CROWDSEC_AGENT_HOST: crowdsec:8080
              GIN_MODE: release
            networks:
              - traefik-proxy
            depends_on:
              - crowdsec

        networks:
          traefik-proxy:
            external: true

      '';
  };
}
