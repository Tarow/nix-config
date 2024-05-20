{ config, vars, lib, ... }:

let
  name = "changedetection";
in
{
  options = {
    docker.${name}.enable = lib.mkEnableOption name;
  };

  config = lib.mkIf config.docker.${name}.enable {
    home.file."docker/${name}/compose.yaml".text =
      ''
        services:
          changedetection:
            container_name: changedetection
            image: dgtlmoon/changedetection.io
            restart: unless-stopped
            volumes:
              - ./data:/datastore
            environment:
              - PUID=1000
              - PGID=1000
              - PLAYWRIGHT_DRIVER_URL=ws://playwright-chrome:3000/?stealth=1&--disable-web-security=true
              - FETCH_WORKERS=1
            labels:
              - traefik.enable=true
              - traefik.http.routers.${name}.rule=Host(`${name}.${vars.hostname}`)
              - traefik.http.routers.${name}.entrypoints=websecure
              - traefik.http.routers.${name}.middlewares=private-chain@file
              - traefik.http.services.${name}.loadbalancer.server.port=5000
            networks:
              - default
              - traefik-proxy

          playwright-chrome:
            container_name: playwright-chrome
            image: browserless/chrome
            restart: unless-stopped

        networks:
          traefik-proxy:
            external: true

      '';
  };
}
