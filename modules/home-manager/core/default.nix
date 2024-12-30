{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.tarow.core;
in {
  options.tarow.core = {
    enable = lib.options.mkEnableOption "Core Programs and Configs";
    configLocation = lib.options.mkOption {
      type = lib.types.nullOr lib.types.str;
      example = "~/nix-config#host";
      default = null;
      description = "Location of the hosts config. If set, an alias 'uh' will be created to apply the home configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      neovim
      jq
      yq-go
    ];

    home.shellAliases.uh = lib.mkIf (cfg.configLocation != null) "home-manager switch -b bak --flake ${cfg.configLocation}";
  };
}
