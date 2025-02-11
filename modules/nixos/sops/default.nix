{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.sops;
in {
  options.tarow.sops = {
    enable = lib.options.mkEnableOption "sops-nix";
    keyFile = lib.options.mkOption {
      type = lib.types.str;
      description = "Path to the key file used to encrypt/decrypt secrets";
    };
  };

  imports = [inputs.sops-nix.nixosModules.sops];

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.sops];
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = cfg.keyFile;

      secrets = {
      };
    };
  };
}
