{ config, pkgs, lib, inputs, outputs, ... }:
{
  system.stateVersion = "24.05";

  tarow = {
    wsl.enable = true;
    shell.enable = true;
    docker.enable = true;
  };

  environment.shellAliases = {
    us = "sudo nixos-rebuild switch --flake ~/projects/nix-config/#wsl2";
  };

  environment.systemPackages = [ pkgs.wget ];
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };
}
