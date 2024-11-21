{ config, pkgs, lib, ... }:
let
  cfg = config.tarow.basics;
in
{
  options.tarow.basics = {
    enable = lib.options.mkOption {
      type = lib.types.bool;
      example = ''true'';
      default = false;
      description = "Whether to install/setup basic programs and configs";
    };
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
      nixpkgs-fmt
      nil
      jq
      yq-go
    ];

    home.shellAliases.uh = lib.mkIf (cfg.configLocation != null) "home-manager switch -b bak --flake ${cfg.configLocation}";
  };
}
