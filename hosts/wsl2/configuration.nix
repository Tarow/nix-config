{ config, pkgs, lib, inputs, outputs, ... }:
{
  system.stateVersion = "24.05";

  tarow = {
    wsl.enable = true;
    shell.enable = true;
  };

  environment.systemPackages = [ pkgs.wget ];
  programs.nix-ld = {
    enable = true;
  };
}
