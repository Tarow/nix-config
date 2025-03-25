{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  tarow.bootLoader.enable = true;
  tarow.shells.enable = true;
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWjCdg7504Sgb/yZGjTBvm5OdRHEv7a7BiP4fOdYo2v niklas@nixos"
  ];

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = lib.mkForce 0;
  networking.firewall.allowedUDPPorts = [80 443 51820];
  networking.firewall.allowedTCPPorts = [80 443];
  networking.hostName = "homeserver";

  system.stateVersion = "24.11";
}
