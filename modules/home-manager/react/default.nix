{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.react;
in {
  options.tarow.react = {
    enable = lib.options.mkOption {
      type = lib.types.bool;
      example = ''true'';
      default = false;
      description = "Whether to enable react support";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      extensions = with pkgs.vscode-marketplace;
      with pkgs.vscode-marketplace-release; [
        dbaeumer.vscode-eslint
        bradlc.vscode-tailwindcss
        dsznajder.es7-react-js-snippets
        formulahendry.auto-rename-tag
      ];
      userSettings = {
        "files.associations" = {
          "*.tsx" = "typescriptreact";
        };
        "[typescriptreact]" = {
          "editor.detectIndentation" = false;
          "editor.tabSize" = 2;
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
      };
    };
  };
}
