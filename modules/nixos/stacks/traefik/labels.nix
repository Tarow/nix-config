{ config, name, port, lib }:
{
  "traefik.http.routers.${name}.rule" = "Host(`${name}.${config.tarow.stacks.traefik.domain}`)";
  "traefik.http.routers.${name}.entrypoints" = "websecure";
  "traefik.http.routers.${name}.middlewares" = "private-chain@file";
} // lib.attrsets.optionalAttrs (port != null) { "traefik.http.services.${name}.loadbalancer.server.port" = "${toString port}"; }
