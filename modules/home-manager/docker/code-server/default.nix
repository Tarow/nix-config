{ config, vars, lib, ... }:

let
  name = "code-server";
in
{
  options = {
    docker.${name}.enable = lib.mkEnableOption name;
  };

  config = lib.mkIf config.docker.${name}.enable {
    home.file."docker/${name}/compose.yaml".text =
      ''
        version: "3.3"

        services:
          code-server:
            image: ghcr.io/linuxserver/code-server
            container_name: code-server
            volumes:
              - ./config:/config
              - /home/niklas:/home/niklas
              - /mnt/hdd1:/hdd
              - /var/run/docker.sock:/var/run/docker.sock
              - /usr/bin/docker:/usr/bin/docker
              - /usr/lib/docker/cli-plugins/docker-compose:/usr/lib/docker/cli-plugins/docker-compose
            restart: unless-stopped
            environment:
              - PUID=1000
              - PGID=1000
              - TZ-Europe/Berlin 
            networks:
              - traefik-proxy
            labels:
              - traefik.enable=true
              - traefik.http.routers.${name}.rule=Host(`code.${vars.hostname}`)
              - traefik.http.routers.${name}.entrypoints=websecure
              - traefik.http.routers.${name}.middlewares=private-chain@file
              - traefik.http.services.${name}.loadbalancer.server.port=8443

        networks:
          traefik-proxy:
            external: true
      '';
  };
}
