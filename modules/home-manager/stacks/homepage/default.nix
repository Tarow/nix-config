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

  toOrderedList = attrs:
    builtins.map (
      groupName: {
        "${groupName}" = builtins.map (
          serviceName: {"${serviceName}" = attrs.${groupName}.${serviceName};}
        ) (builtins.attrNames attrs.${groupName});
      }
    ) (builtins.sort (
      a: b: let
        orderA = attrs.${a}.order or 999;
        orderB = attrs.${b}.order or 999;
      in
        if orderA == orderB
        then a < b
        else orderA < orderB
    ) (builtins.attrNames attrs));

  homepageContainers = builtins.filter (c: c.homepage.settings != {}) (builtins.attrValues config.services.podman.containers);

  mergedServices =
    builtins.foldl' (
      acc: c: let
        category = c.homepage.category;
        serviceName = c.homepage.name;
        serviceSettings = c.homepage.settings;
        existingServices = acc.${category} or {};
      in
        acc
        // {
          "${category}" = existingServices // {"${serviceName}" = serviceSettings;};
        }
    ) {}
    homepageContainers;
in {
  imports = [
    {
      tarow.stacks.homepage.services = mergedServices;
    }
  ];

  options.services.podman.containers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({...}: {
      options.homepage = with lib; {
        category = options.mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        name = options.mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        settings = options.mkOption {
          type = types.attrsOf types.anything;
          default = {};
        };
      };
    }));
  };

  options.tarow.stacks.${name} = {
    enable = lib.mkEnableOption name;
    bookmarks = lib.mkOption {
      inherit (yaml) type;
      default = [];
    };
    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
      apply = x: toOrderedList x;
      default = {};
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
    services.podman.containers.${name} = {
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
      };
      environmentFile = [config.sops.secrets."homepage/env".path];
      port = 3000;
      traefik.name = name;
    };

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
            units = "metric";
            cache = 5;
            apiKey = "{{HOMEPAGE_VAR_OPENWEATHERMAP_API_KEY}}";
          };
        }
      ];
    };
  };
}
