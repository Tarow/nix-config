{ lib, pkgs, config, ... }:
let
  cfg = config.tarow.angular;
in
{
  options.tarow.angular = {
    enable = lib.options.mkEnableOption "Angular";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      home.packages = with pkgs;[ nodePackages."@angular/cli" ];
      extensions = with pkgs.vscode-marketplace; with pkgs.vscode-marketplace-release;
        [
          angular.ng-template
          bradlc.vscode-tailwindcss
          formulahendry.auto-rename-tag
        ];
      userSettings = { };
    };
  };
}
