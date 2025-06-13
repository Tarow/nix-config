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

  sortByRank = attrs:
    builtins.sort (
      a: b: let
        orderA = attrs.${a}.order or 999;
        orderB = attrs.${b}.order or 999;
      in
        if orderA == orderB
        then (lib.strings.toLower a) < (lib.strings.toLower b)
        else orderA < orderB
    ) (builtins.attrNames attrs);

  toOrderedList = attrs:
    builtins.map (
      groupName: {
        "${groupName}" = builtins.map (
          serviceName: {"${serviceName}" = attrs.${groupName}.${serviceName};}
        ) (sortByRank attrs.${groupName});
      }
    ) (sortByRank attrs);
in {
  imports = [./extension.nix];

  options.tarow.stacks.${name} = {
    enable = lib.mkEnableOption name;
    bookmarks = lib.mkOption {
      inherit (yaml) type;
      default = [];
    };
    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
      apply = toOrderedList;
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
        "${config.tarow.podman.socketLocation}:/var/run/docker.sock:ro"
      ];
      environment = {
        PUID = config.tarow.stacks.defaultUid;
        PGID = config.tarow.stacks.defaultGid;
        HOMEPAGE_ALLOWED_HOSTS = config.services.podman.containers.${name}.traefik.serviceHost;
      };
      environmentFile = [config.sops.secrets."homepage/env".path];
      port = 3000;
      traefik = {
        inherit name;
        subDomain = "";
      };
    };

    tarow.stacks.${name} = {
      docker.local.socket = "/var/run/docker.sock";

      settings.statusStyle = "dot";

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
