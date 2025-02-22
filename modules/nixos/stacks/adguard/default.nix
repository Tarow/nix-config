{
  lib,
  config,
  ...
}: let
  name = "adguard";
  cfg = config.tarow.stacks.${name};
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";

  stack = {
    services.${name}.service = {
      image = "adguard/adguardhome:latest";
      volumes = [
        "${storage}/work:/opt/adguardhome/work"
        "${storage}/conf:/opt/adguardhome/conf"
      ];
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "853:853/tcp"
      ];
    };
  };
in {
  imports = [
    (import ../base.nix {
      inherit name;
      port = 3000;
    })
  ];

  config = lib.mkIf cfg.enable {
    virtualisation.arion.projects.${name}.settings = stack;
  };
}
