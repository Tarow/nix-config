{ config, vars, lib, ... }:

let
  name = "authelia";
in
{
  options = {
    docker.${name}.enable = lib.mkEnableOption name;
  };

  config = lib.mkIf config.docker.${name}.enable {
    home.file."docker/${name}/compose.yaml".text =
      ''
        services:
          authelia:
            container_name: authelia
            image: authelia/authelia:latest
            restart: unless-stopped
            volumes:
              - ./config:/config
            environment:
              TZ: "Europe/Berlin"
              PUID: 1000
              PGID: 1000
            labels:
              - traefik.enable=true
              - traefik.http.routers.${name}.rule=Host(`auth.${vars.hostname}`)
              - traefik.http.routers.${name}.entrypoints=websecure
              - traefik.http.routers.${name}.middlewares=public-chain@file
              - traefik.http.services.${name}.loadbalancer.server.port=9091
              - dockdns.name=auth.${vars.hostname}
            networks:
              - traefik-proxy

        networks:
          traefik-proxy:
            external: true
      '';
  };
}
