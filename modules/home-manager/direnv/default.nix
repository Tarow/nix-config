{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.direnv;
in {
  options.tarow.direnv = {
    enable = lib.options.mkEnableOption "direnv";
  };
  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      # Always enabled on fish
      # enableFishIntegration = true;
      nix-direnv.enable = true;

      config = {
        warn_timeout = 0;
      };
    };

    programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace;
    with pkgs.vscode-marketplace-release; [
      mkhl.direnv
    ];
  };
}
