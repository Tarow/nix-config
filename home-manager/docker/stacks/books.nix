{ config, vars, lib, ... }:

let
  name = "books";
in
{
  options = {
    docker.${name}.enable = lib.mkEnableOption name;
  };

  config = lib.mkIf config.docker.${name}.enable {
    home.file."docker/${name}/compose.yaml".text =
      ''
        services:
          audiobookshelf:
            image: ghcr.io/advplyr/audiobookshelf
            container_name: audiobookshelf
            user: "1000:1000"
            volumes:
              - /mnt/hdd1/media/audiobooks:/audiobooks
              - ./podcasts:/podcasts
              - ./metadata:/metadata
              - ./config:/config
            restart: unless-stopped
            networks:
              - traefik-proxy
            labels:
              - traefik.enable=true
              - traefik.http.routers.audiobookshelf.rule=Host(`audiobookshelf.${vars.hostname}`)
              - traefik.http.routers.audiobookshelf.entrypoints=websecure
              - traefik.http.routers.audiobookshelf.middlewares=public-chain@file
              - traefik.http.services.audiobookshelf.loadbalancer.server.port=80
              - dockdns.name=audiobookshelf.${vars.hostname}

          readarr-ebooks:
            image: lscr.io/linuxserver/readarr:develop
            container_name: readarr-ebooks
            environment:
              - PUID=1000
              - PGID=1000
              - TZ=Europe/Berlin
            volumes:
              - ./readarr-ebooks-config:/config
              - /mnt/hdd1/media:/media
            restart: unless-stopped
            networks:
              - traefik-proxy
            labels:
              - "traefik.enable=true"
              - "traefik.http.routers.readarr-ebooks.rule=Host(`readarr-ebooks.${vars.hostname}`)"
              - "traefik.http.routers.readarr-ebooks.entrypoints=websecure"
              - "traefik.http.routers.readarr-ebooks.middlewares=private-chain@file"
              - "traefik.http.services.readarr-ebooks.loadbalancer.server.port=8787"

          readarr-audiobooks:
            image: lscr.io/linuxserver/readarr:develop
            container_name: readarr-audiobooks
            environment:
              - PUID=1000
              - PGID=1000
              - TZ=Europe/Berlin
            volumes:
              - ./readarr-audiobooks-config:/config
              - /mnt/hdd1/media:/media
            restart: unless-stopped
            networks:
              - traefik-proxy
            labels:
              - "traefik.enable=true"
              - "traefik.http.routers.readarr-audiobooks.rule=Host(`readarr-audiobooks.${vars.hostname}`)"
              - "traefik.http.routers.readarr-audiobooks.entrypoints=websecure"
              - "traefik.http.routers.readarr-audiobooks.middlewares=private-chain@file"
              - "traefik.http.services.readarr-audiobooks.loadbalancer.server.port=8787"

        networks:
          traefik-proxy:
            external: true

      '';
  };
}
