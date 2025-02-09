{
  config,
  lib,
  ...
}: let
  name = "filebrowser";
  cfg = config.tarow.stacks.${name};
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";

  stack = {
    services.${name}.service = {
      image = "filebrowser/filebrowser:s6";
      volumes = [
        "${storage}/database:/database"
        "${storage}/config:/config"
        "/:/srv"
      ];
      environment = {
        PUID = config.tarow.stacks.uid;
        PGID = config.tarow.stacks.gid;
      };
    };
  };
in {
  imports = [
    (import ../base.nix {
      inherit name;
      port = 80;
    })
  ];
  config = lib.mkIf cfg.enable {
    virtualisation.arion.projects.${name}.settings = stack;
  };
}
