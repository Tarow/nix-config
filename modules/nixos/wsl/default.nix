{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.tarow.wsl;
in
{
  imports = [ inputs.nixos-wsl.nixosModules.default ];

  options.tarow.wsl = {
    enable = lib.options.mkOption {
      type = lib.types.bool;
      example = ''true'';
      default = false;
      description = "Whether to enable WSL support.";
    };
  };

  config = lib.mkIf cfg.enable {
    wsl.enable = true;
    wsl.defaultUser = "niklas";
  };
}