{ pkgs, lib, config, inputs, ... }:
let
  name = "adguard";
  cfg = config.tarow.stacks.${name};

  stack = {
    networks.${config.tarow.stacks.traefik.network}.external = lib.mkIf cfg.addToTraefik true;
    services.${name}.service = lib.mkMerge [
      {
        image = "adguard/adguardhome:latest";
        container_name = name;
        restart = "unless-stopped";
        volumes = [
          "${config.tarow.stacks.storageBaseDir}/${name}/work:/opt/adguardhome/work"
          "${config.tarow.stacks.storageBaseDir}/${name}/conf:/opt/adguardhome/conf"
        ];
        ports = [
          "53:53/tcp"
          "53:53/udp"
          "853:853/tcp"
        ] ++ lib.lists.optional (!cfg.addToTraefik) "3000:3000";
      }
      (lib.mkIf cfg.addToTraefik {
        labels = (import ../traefik/labels.nix { inherit name config lib; port = 3000; });
        networks = [ config.tarow.stacks.traefik.network ];
      })
    ];
  };
in
{
  options.tarow.stacks.${name} = with lib; {
    enable = options.mkEnableOption name;
    addToTraefik = options.mkOption {
      type = types.bool;
      default = config.tarow.stacks.traefik.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.arion.projects.${name}.settings = stack;
  };
}
