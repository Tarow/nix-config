{config, vars, lib, ...}:

let
  name = "adguard";
in
{
  options = {
    docker.${name}.enable = lib.mkEnableOption name;
  };
  
  config = lib.mkIf config.docker.${name}.enable {
    home.file."docker/${name}/compose.yaml".text =
      ''
      services:
        adguard:
          image: adguard/adguardhome:latest
          container_name: ${name}
          restart: unless-stopped
          volumes:
            - ./work:/opt/adguardhome/work
            - ./conf:/opt/adguardhome/conf
          ports:
            - 10.1.1.99:53:53/tcp
            - 10.1.1.99:53:53/udp
            - 10.1.1.99:853:853/tcp
      #      - 10.1.1.99:3000:3000
          labels:
            - traefik.enable=true
            - traefik.http.routers.${name}.rule=Host(`adguard.${vars.hostname}`)
            - traefik.http.routers.${name}.entrypoints=websecure
            - traefik.http.routers.${name}.middlewares=private-chain@file
            - traefik.http.services.${name}.loadbalancer.server.port=3000
          networks:
            - traefik-proxy
      networks:
        traefik-proxy:
          external: true
    '';
  };
}