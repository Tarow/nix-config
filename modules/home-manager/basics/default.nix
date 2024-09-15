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
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nixpkgs-fmt
      nil
      jq
      yq-go
    ];
  };
}
