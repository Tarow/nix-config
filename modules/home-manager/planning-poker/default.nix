{
  config,
  lib,
  ...
}: let
  name = "planning-poker";

  cfg = config.nps.stacks.${name};
  storage = "${config.nps.storageBaseDir}/${name}";

  src = builtins.fetchGit {
    url = "https://github.com/Cyclenerd/scrumpoker";
    ref = "master";
    rev = "256a04b4313c602b534241705ec1ca93d3e2a7eb";
  };
  tag = "localhost/cyclenerd/scrumpoker:latest";
in {
  options.nps.stacks.${name}.enable = lib.mkEnableOption name;

  config = lib.mkIf cfg.enable {
    services.podman = {
      builds.scrumpoker = {
        file = "${src}/Dockerfile";
        tags = [tag];
      };
      containers = {
        ${name} = {
          image = tag;
          volumes = [
            "${storage}/db:/var/lib/database"
          ];
          port = 8080;

          traefik.name = "poker";
          expose = true;

          dependsOn = ["podman-scrumpoker-build.service"];
        };
      };
    };
  };
}
