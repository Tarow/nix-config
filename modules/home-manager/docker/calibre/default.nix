{ config, vars, lib, ... }:

let
  name = "calibre";
in
{
  options = {
    docker.${name}.enable = lib.mkEnableOption name;
  };

  config = lib.mkIf config.docker.${name}.enable {
    home.file."docker/${name}/compose.yaml".text =
      ''
        services:
          calibre:
            image: lscr.io/linuxserver/calibre-web
            container_name: calibre-web
            environment:
              - PUID=1000
              - PGID=1000
              - TZ=Europe/Berlin
              # - DOCKER_MODS=linuxserver/mods:universal-calibre # optional for ebook conversion
              - OAUTHLIB_RELAX_TOKEN_SCOPE=1 # optional for Google OAuth
            volumes:
              - ./config:/config
              - ./books:/books
            restart: unless-stopped
            networks:
              - traefik-proxy
            labels:
              - traefik.enable=true
              - traefik.http.routers.${name}.rule=Host(`${name}.${vars.hostname}`)
              - traefik.http.routers.${name}.entrypoints=websecure
              - traefik.http.routers.${name}.middlewares=private-chain@file
              - traefik.http.services.${name}.loadbalancer.server.port=8083

        networks:
          traefik-proxy:
            external: true
      '';
  };
}
