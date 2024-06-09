{ config, vars, lib, ... }:

let
  name = "bookstack";
in
{
  options = {
    docker.${name}.enable = lib.mkEnableOption name;
  };

  config = lib.mkIf config.docker.${name}.enable {
    home.file."docker/${name}/compose.yaml".text =
      ''
        services:
          bookstack:
            image: lscr.io/linuxserver/bookstack
            container_name: bookstack
            env_file:
              - bookstack.env
            environment:
              - PUID=1000
              - PGID=1000
              - DB_HOST=bookstack_db
              - DB_PORT=3306
              - DB_USER=bookstack
              - DB_DATABASE=bookstackapp
            volumes:
              - ./bookstack-data:/config
            restart: unless-stopped
            depends_on:
              - bookstack_db
            networks:
              - traefik-proxy
              - default
            labels:
              - traefik.enable=true
              - traefik.http.routers.${name}.rule=Host(`${name}.${vars.hostname}`)
              - traefik.http.routers.${name}.entrypoints=websecure
              - traefik.http.routers.${name}.middlewares=private-chain@file
              - traefik.http.services.${name}.loadbalancer.server.port=80

          bookstack_db:
            image: lscr.io/linuxserver/mariadb
            container_name: bookstack_db
            # Contains MYSQL_PASSWORD and MYSQL_ROOT_PASSWORD
            env_file:
              - db.env
            environment:
              - PUID=1000
              - PGID=1000
              - TZ=Europe/Berlin
              - MYSQL_DATABASE=bookstackapp
              - MYSQL_USER=bookstack
            volumes:
              - ./db:/config
            restart: unless-stopped

        networks:
          traefik-proxy:
            external: true
      '';
  };
}
