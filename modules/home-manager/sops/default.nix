{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.sops;

  # Read encrypted secrets from secret file (without sops config key)
  secrets = lib.removeAttrs (lib.tarow.readYAML config.sops.defaultSopsFile) ["sops"];

  /* Flatten and extract all nested keys, e.g
    a:
      b:
        c: 1
    d: 2
    => ["a/b/c", "d"]
  */
  secretKeys = lib.tarow.flattenAttrs "" "/" secrets;
  
  /* Map all keys to a default secret config. E.g.
    ["a/b/c", "d"] => { "a/b/c" = { }; "d" = { }; }
  */
  secretCfg = secretKeys |> map (k: { name = k; value = { }; }) |> builtins.listToAttrs;
in {
  options.tarow.sops = {
    enable = lib.options.mkEnableOption "sops-nix";
    keyFile = lib.options.mkOption {
      type = lib.types.str;
      description = "Path to the key file used to encrypt/decrypt secrets";
      default = "${config.xdg.configHome}/sops/age/keys.txt";
    };
  };

  imports = [inputs.sops-nix.homeManagerModules.sops];

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.sops];
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = cfg.keyFile;

      secrets = secretCfg;
    };
  };
}
