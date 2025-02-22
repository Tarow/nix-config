# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x13-amd
  ];

  system.stateVersion = "24.05";

  tarow = lib.mkMerge [
    (lib.tarow.enableModules [
      "bootLoader"
      "core"
      "gnome"
      "keyboard"
      "locale"
      "networkManager"
      "pipewire"
      "printing"
      "shells"
    ])
    {core.configLocation = "~/nix-config#thinkpad";}
  ];

  networking.hostName = "nixos";
  users.users.niklas = {
    isNormalUser = true;
    description = "Niklas";
    extraGroups = ["wheel" (lib.mkIf config.tarow.networkManager.enable "networkmanager")];
    shell = pkgs.fish;
  };

  services.fprintd.enable = false;
}
