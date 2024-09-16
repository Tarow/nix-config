{ config, pkgs, lib, inputs, outputs, ... }:
{
  system.stateVersion = "24.05";

  tarow = {
    wsl.enable = true;
    shell.enable = true;
    podman.enable = true;
    docker.enable = false;
    stacks = {
      adguard.enable = true;
      audiobookshelf.enable = true;
      readarr-audiobooks.enable = true;
      readarr-ebooks.enable = true;
      calibre-web.enable = true;
      traefik = {
        enable = true;
        network = "traefik-proxy";
        domain = "ntasler.de";
      };
    };

  };

  environment.shellAliases = {
    us = "sudo nixos-rebuild switch --flake ~/projects/nix-config/#wsl2";
  };

  environment.systemPackages = [ pkgs.wget ];
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  users.users.${config.wsl.defaultUser} = {
    shell = pkgs.fish;
  };
}
