{ config, vars, lib, ... }:

let
  name = "cloudflare-ddns";
in
{
  options = {
    docker.${name}.enable = lib.mkEnableOption name;
  };

  config = lib.mkIf config.docker.${name}.enable {
    home.file."docker/${name}/compose.yaml".text =
      ''
        services:
          cloudflare-ddns:
            image: timothyjmiller/cloudflare-ddns:latest
            container_name: cloudflare-ddns
            security_opt:
              - no-new-privileges:true
            network_mode: 'host'
            environment:
              - PUID=1000
              - PGID=1000
            volumes:
              - ./config.json:/config.json
            restart: unless-stopped
      '';
  };
}
