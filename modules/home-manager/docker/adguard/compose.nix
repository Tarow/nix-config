{
  services = {
    adguard = {
      image = "adguard/adguardhome:latest";
      container_name = "adguard";
      restart = "unless-stopped";
      volumes = [
        "./work:/opt/adguardhome/work"
        "./conf:/opt/adguardhome/conf"
      ];
      ports = [
        "10.1.1.99:53:53/tcp"
        "10.1.1.99:53:53/udp"
        "10.1.1.99:853:853/tcp"
      ];
    };
  };
}
