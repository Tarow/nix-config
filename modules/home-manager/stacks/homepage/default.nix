{config, ...}: let
  name = "calibre";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";

  container = {
    image = "lscr.io/linuxserver/calibre-web";
    volumes = [
      "${storage}/config:/config"
      "${storage}/books:/books"
    ];
    environment = {
      PUID = config.tarow.stacks.defaultUid;
      PGID = config.tarow.stacks.defaultGid;
    };
  };
in {
  imports = [
    (import ../mkContainer.nix {
      inherit name container;
      port = 8083;
    })
  ];
}
