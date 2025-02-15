{config, ...}: let
  name = "calibre";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";

  container = {
    image = "lscr.io/linuxserver/calibre-web";
    volumes = [
      "${storage}/config:/config"
      "${storage}/books:/books"
    ];
    environment.OAUTHLIB_RELAX_TOKEN_SCOPE = 1;
  };
in {
  imports = [
    (import ../mkContainer.nix {
      inherit name container;
      port = 8083;
    })
  ];
}
