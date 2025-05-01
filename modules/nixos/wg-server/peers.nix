config: {
  homeserver = {
    name = "homeserver";
    endpoint = "vpn.ntasler.de";
    publicKey = "hh/YZ5sBzDH9ow10JkH0VUhpl5yGzcNteCtaWF2q9TA=";
  };
  niklas-phone = {
    name = "niklas-phone";
    publicKey = "NqjXYy3NzgQVSjAvzp/AevGmENxIA6/XdXzZZy87PRA=";
    presharedKeyFile = config.sops.secrets."wireguard/psk_phone".path;
    allowedIPs = ["10.2.2.2"];
  };
}
