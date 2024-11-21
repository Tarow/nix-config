{ lib, pkgs, config, ... }:
let
  cfg = config.tarow.shells;
in
{
  options.tarow.shells = {
    enable = lib.options.mkOption {
      type = lib.types.bool;
      example = ''true'';
      default = false;
      description = "Whether to enable shell support";
    };
  };

  config = lib.mkIf cfg.enable {

    # Enable shell support, bash is always enabled
    programs.fish.enable = true;
    programs.zsh.enable = true;
  };
}
