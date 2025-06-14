{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.starship;
in {
  options.tarow.starship.enable = lib.mkEnableOption "Starship Prompt";

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      settings = import ./settings.nix lib;
    };
  };
}
