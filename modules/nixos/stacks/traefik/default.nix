{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  name = "traefik";
  cfg = config.tarow.docker.${name};
in {
  options.tarow.stacks.${name} = {
    enable = lib.options.mkEnableOption name;
    domain = lib.options.mkOption {
      type = lib.types.str;
      description = "Base domain handled by Traefik";
    };
    network = lib.options.mkOption {
      type = lib.types.str;
      description = "Network for the Traefik docker provider";
    };
  };

  config = lib.mkIf cfg.enable {
    #home.file."${config.tarow.docker.stackDir}/${name}/compose.yml".text = lib.generators.toYAML { } (import ./compose.nix);
  };
}
