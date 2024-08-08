{ lib, config, pkgs, ... }:
let
  cfg = config.luna.traefik;

  certs = pkgs.runCommand "certs" { } ''
    HOME=$TMPDIR
    mkdir $out
    ${pkgs.mkcert}/bin/mkcert -cert-file $out/${cfg.hostName}.pem -key-file $out/${cfg.hostName}-key.pem "${cfg.hostName}" "*.${cfg.hostName}"
  '';

  dynamicConfig = {
    http = {
      routers = {
        dashboard = {
          rule = "Host(`traefik.${cfg.hostName}`)";
          entrypoints = [ "websecure" ];
          service = "api@internal";
        };
      };
    };
    tls = {
      certificates = [
        {
          certFile = "${certs}/${cfg.hostName}.pem";
          keyFile = "${certs}/${cfg.hostName}-key.pem";
        }
      ];
    };
  };

  staticConfig = {
    entryPoints = {
      web = {
        address = ":80";
        http.redirections.entryPoint = {
          to = "websecure";
          scheme = "https";
        };
      };
      websecure = {
        address = ":443";
        http.tls = { };
      };
    };

    serversTransport.insecureSkipVerify = true;

    api.dashboard = true;

    providers = {
      docker = {
        exposedByDefault = false;
        network = "traefik-proxy";
        defaultRule = ''Host(`{{ coalesce (index .Labels "com.docker.compose.service") (normalize .Name) }}.${cfg.hostName}`)'';
      };
    };
    accessLog.format = "json";
    log.level = "WARN";
  };
in
{
  options.luna.traefik = {
    enable = lib.mkEnableOption "traefik";
    hostName = lib.options.mkOption {
      type = lib.types.str;
      example = "dev.box";
      default = "dev.box";
      description = "Base hostname. Any services added to traefik, will be subdomains of the hostname.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.traefik = {
      enable = true;
      group = "docker";
      dynamicConfigOptions = dynamicConfig;
      staticConfigOptions = staticConfig;
    };
  };
}
