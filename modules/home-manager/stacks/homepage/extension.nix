{config, ...}: let
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
}
