{
  config,
  lib,
  ...
}: let
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
    type = lib.types.attrsOf (lib.types.submodule ({
      name,
      config,
      ...
    }: {
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
          apply = settings:
            if settings == {}
            then {}
            else
              ({
                  href = config.traefik.serviceDomain or "";
                  server = "local";
                  container = name;
                }
                // settings);
        };
      };
    }));
  };
}
