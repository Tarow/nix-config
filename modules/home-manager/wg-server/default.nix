{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.wg-server;
in {
  options.tarow.wg-server = with lib; {
    enable = mkEnableOption "Wireguard Server";
    port = mkOption {
      type = types.port;
      default = 51820;
    };
    internalInterface = mkOption {
      type = types.str;
      default = "wg0";
    };
    externalInterface = mkOption {
      type = types.str;
      default = "enp1s0";
    };
    ip = mkOption {
      type = types.str;
      default = "10.10.10.1/24";
    };
  };
  config = lib.mkIf cfg.enable {
    networking.nat.enable = true;
    networking.nat.externalInterface = cfg.externalInterface;
    networking.nat.internalInterfaces = cfg.internalInterface;
    networking.firewall = {
      allowedUDPPorts = [cfg.port];
    };

    networking.wireguard.interfaces = {
      wg0 = {
        ips = [cfg.ip];
        listenPort = cfg.port;

        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${cfg.ip} -o ${cfg.externalInterface} -j MASQUERADE
        '';

        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${cfg.ip} -o ${cfg.externalInterface} -j MASQUERADE
        '';

        privateKeyFile = config.sops.secrets."wireguard/pk".path;

        peers = [
        ];
      };
    };
  };
}
