{ config, name, port, lib }:
[
  "traefik.http.routers.${name}.rule=Host(`${name}.${config.tarow.docker.traefik.domain}`)"
  "traefik.http.routers.${name}.entrypoints=websecure"
  "traefik.http.routers.${name}.middlewares=private-chain@file"
] ++ lib.lists.optional (port != null) "traefik.http.services.${name}.loadbalancer.server.port=${toString port}"
