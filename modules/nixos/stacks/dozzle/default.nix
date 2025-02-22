{
  lib,
  config,
  ...
}: let
  name = "dozzle";
  cfg = config.tarow.stacks.${name};

  stack = {
    services.${name}.service = {
      image = "amir20/dozzle:latest";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
    };
  };
in {
  imports = [
    (import ../base.nix {
      inherit name;
      port = 8080;
    })
  ];

  config = lib.mkIf cfg.enable {
    virtualisation.arion.projects.${name}.settings = stack;
  };
}
