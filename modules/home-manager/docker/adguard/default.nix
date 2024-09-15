{ pkgs, lib, config, inputs, ... }:
let
  name = "adguard";
  cfg = config.tarow.docker.${name};

  networkCfg = lib.attrsets.optionalAttrs cfg.addToTraefik {
    services.${name}.labels = (import ../traefik/labels.nix { inherit name config lib; port = 3000; });
    networks.${config.tarow.docker.traefik.network}.external = true;
  };
in
{


  options.tarow.docker.${name} = with lib; {
    enable = options.mkEnableOption name;
    composeDefinition = lib.options.mkOption {
      type = types.attrsOf types.anything;
      default = (import ./compose.nix);
    };
    extraConfig = options.mkOption {
      type = types.attrsOf types.anything;
      default = { };
    };
    addToTraefik = options.mkOption {
      type = types.bool;
      default = config.tarow.docker.traefik.enable;
    };
  };


  config =
    let
      composeFile = lib.generators.toYAML { } (lib.tarow.recursiveMerge [ cfg.composeDefinition cfg.extraConfig networkCfg ]);
    in
    lib.mkIf cfg.enable {
      home.file."${config.tarow.docker.stackDir}/${name}/compose.yml".text = composeFile;
      #home.file."test.json".text = builtins.toJSON cfg.composeDefinition;
    };
}
