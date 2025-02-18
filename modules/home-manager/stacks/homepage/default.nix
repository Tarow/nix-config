{
  config,
  pkgs,
  lib,
  ...
}: let
  name = "homepage";
  mediaStorage = config.tarow.stacks.mediaStorageBaseDir;
  cfg = config.tarow.stacks.${name};
  yaml = pkgs.formats.yaml {};

  container = {
    image = "ghcr.io/gethomepage/homepage:latest";
    volumes = [
      "${mediaStorage}:/mnt/hdd1:ro"
      "${yaml.generate "docker.yaml" cfg.docker}:/app/config/docker.yaml"
      "${yaml.generate "services.yaml" cfg.services}:/app/config/services.yaml"
      "${yaml.generate "settings.yaml" cfg.settings}:/app/config/settings.yaml"
      "${yaml.generate "widgets.yaml" cfg.widgets}:/app/config/widgets.yaml"
      "${yaml.generate "bookmarks.yaml" cfg.bookmarks}:/app/config/bookmarks.yaml"
      "/run/user/1000/podman/podman.sock:/var/run/docker.sock:ro"
    ];
    environment = {
      PUID = config.tarow.stacks.defaultUid;
      PGID = config.tarow.stacks.defaultGid;
      LOG_LEVEL = "debug";
    };
    environmentFile = [config.sops.secrets."homepage/env".path];
  };
in {
  imports = [
    (import ../mkContainer.nix {
      inherit name container;
      port = 3000;
    })
  ];

  options.tarow.stacks.${name} = {
    bookmarks = lib.mkOption {
      inherit (yaml) type;
      default = [];
    };
    services = lib.mkOption {
      inherit (yaml) type;
      default = [];
    };
    widgets = lib.mkOption {
      inherit (yaml) type;
      default = [];
    };
    docker = lib.mkOption {
      inherit (yaml) type;
      default = {};
    };
    settings = lib.mkOption {
      inherit (yaml) type;
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    tarow.stacks.${name} = {
      docker.local.socket = "/var/run/docker.sock";

      widgets = [
        {
          resources = {
            cpu = true;
            memory = true;
            label = "System";
          };
        }
        {
          resources = {
            disk = "/";
            label = "SSD";
          };
        }
        {
          resources = {
            disk = "/mnt/hdd1";
            label = "HDD";
          };
        }
        {
          search = {
            provider = "google";
            focus = true;
            target = "_blank";
          };
        }
        {
          openweathermap = {
            latitude = "51.960667";
            longitude = "7.626135";
            units = "metric";
            cache = 5;
            apiKey = "{{HOMEPAGE_VAR_OPENWEATHERMAP_API_KEY}}";
          };
        }
      ];
    };
  };
}
