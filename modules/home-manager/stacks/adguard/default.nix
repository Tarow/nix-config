{config, ...}: let
  name = "adguard";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";

  container = {
    image = "docker.io/adguard/adguardhome:latest";
    volumes = [
      "${storage}/work:/opt/adguardhome/work"
      "${storage}/conf:/opt/adguardhome/conf"
    ];
    ports = [
      #"53:53/tcp"
      #"53:53/udp"
      #"853:853/tcp"
      "3000:3000"
    ];
  };
in {
  imports = [
    (import ../mkContainer.nix {
      inherit name container;
      port = 3000;
    })
  ];
}
