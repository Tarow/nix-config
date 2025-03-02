{
  config,
  lib,
  ...
}: let
  name = "calibre";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};
in {
  options.tarow.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "docker.io/crocodilestick/calibre-web-automated:latest";
      volumes = [
        "${storage}/config:/config"
        "${storage}/ingest:/cwa-book-ingest"
        "${storage}/library:/calibre-library"
      ];
      environment = {
        PUID = config.tarow.stacks.defaultUid;
        PGID = config.tarow.stacks.defaultGid;
        TZ = config.tarow.stacks.defaultTz;
      };
      port = 8083;

      stack = name;
      traefik.name = name;
      homepage = {
        category = "General";
        name = "Calibre";
        settings = {
          description = "Ebook Library";
          icon = "calibre-web";
        };
      };
    };

    services.podman.containers."${name}-downloader" = let
      ingestDir = "/cwa-book-ingest";
      port = 8084;
    in {
      image = "ghcr.io/calibrain/calibre-web-automated-book-downloader:latest";
      environment = {
        FLASK_PORT = port;
        FLASK_DEBUG = false;
        CLOUDFLARE_PROXY_URL = "http://cloudflarebypassforscraping:8000";
        INGEST_DIR = ingestDir;
        BOOK_LANGUAGE = "en,de";
      };
      volumes = [
        "${storage}/ingest:${ingestDir}"
      ];

      port = port;
      stack = name;
      traefik.name = "calibre-downloader";
      homepage = {
        category = "General";
        name = "Calibre Downloader";
        settings = {
          description = "Ebook Library";
          icon = "calibre-web";
        };
      };
    };

    services.podman.containers.cloudflarebypassforscraping = {
      image = "ghcr.io/sarperavci/cloudflarebypassforscraping:latest";
      stack = name;
    };
  };
}
