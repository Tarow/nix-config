{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.sops;

  # Read encrypted secrets from secret file (without sops config key)
  readSecrets = file: lib.removeAttrs (lib.tarow.readYAML file) ["sops"];

  /*
   Flatten and extract all nested keys, e.g
  a:
    b:
      c: 1
  d: 2
  => ["a/b/c", "d"]
  */
  getSecretKeys = secrets: lib.tarow.flattenAttrs "" "/" secrets;

  /*
   Map all keys to a default secret config. E.g.
  ["a/b/c", "d"] => { "a/b/c" = {owner = ...; group = ...;}; "d" = {owner = ...; group = ...;}; }
  */
  mapSecrets = secretKeys:
    secretKeys
    |> map (k: {
      name = k;
      value = {};
    })
    |> builtins.listToAttrs;

  getSecretCfg = sopsFile:
    readSecrets sopsFile
    |> getSecretKeys
    |> mapSecrets
    |> lib.mapAttrs (_: v: v // {inherit sopsFile;});

  fullCfg =
    ([config.sops.defaultSopsFile] ++ cfg.extraSopsFiles)
    |> map getSecretCfg
    |> lib.mergeAttrsList;
in {
  options.tarow.sops = {
    enable = lib.options.mkEnableOption "sops-nix";
    extraSopsFiles = lib.options.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [];
      description = "Path to extra sops files containing encrypted secrets";
    };
    keyFile = lib.options.mkOption {
      type = lib.types.str;
      description = "Path to the key file used to decrypt secrets";
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

      secrets = fullCfg;
    };
  };
}
