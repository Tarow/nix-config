{
  modulesPath,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    #./hardware-configuration.nix
  ];

  tarow.bootLoader.enable = true;
  tarow.shells.enable = true;
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWjCdg7504Sgb/yZGjTBvm5OdRHEv7a7BiP4fOdYo2v niklas@nixos"
  ];

  system.stateVersion = "24.05";
}
