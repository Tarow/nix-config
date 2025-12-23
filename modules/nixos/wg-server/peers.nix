config: {
  homeserver = {
    name = "homeserver";
    endpoint = "vpn.ntasler.de:51820";
    publicKey = "hh/YZ5sBzDH9ow10JkH0VUhpl5yGzcNteCtaWF2q9TA=";
    presharedKeyFile = config.sops.secrets."wireguard/psk_homeserver".path;
    allowedIPs = ["10.1.1.0/24" "10.2.2.0/24"];
  };
  relsat-server = {
    name = "relsat";
    endpoint = "vpn.relsat.de:51820";
    publicKey = "hh/YZ5sBzDH9ow10JkH0VUhpl5yGzcNteCtaWF2q9TA=";
    presharedKeyFile = config.sops.secrets."wireguard/psk_relsat".path;
    allowedIPs = ["192.168.178.0/24" "10.3.3.0/24"];
  };
  niklas-phone = {
    name = "niklas-phone";
    publicKey = "NqjXYy3NzgQVSjAvzp/AevGmENxIA6/XdXzZZy87PRA=";
    presharedKeyFile = config.sops.secrets."wireguard/psk_phone".path;
    allowedIPs = ["10.2.2.2"];
  };
  niklas-tablet = {
    name = "niklas-tablet";
    publicKey = "lURD4fWoIGJ3heRCNuwu2AQWCIyfsF69KFX5cNkln1w=";
    presharedKeyFile = config.sops.secrets."wireguard/psk_tablet".path;
    allowedIPs = ["10.2.2.3"];
  };
}
