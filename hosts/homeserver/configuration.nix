{
  config,
  lib,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  tarow = {
    core = {
      enable = true;
      configLocation = "~/nix-config#homeserver";
    };
    bootLoader.enable = true;
    shells.enable = true;
    sops.enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  users.mainUser.openssh.authorizedKeys.keyFiles = [
    config.sops.secrets."ssh_authorized_keys".path
  ];

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = lib.mkForce 0;
  networking.firewall.allowedUDPPorts = [80 443 51820];
  networking.firewall.allowedTCPPorts = [80 443];
  networking.hostName = "homeserver";

  system.stateVersion = "24.11";
}
