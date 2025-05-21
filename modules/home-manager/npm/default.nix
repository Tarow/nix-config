{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.npm;
in {
  options.tarow.npm = {
    enable = lib.options.mkOption {
      type = lib.types.bool;
      example = ''true'';
      default = false;
      description = "Whether to enable vscode";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.nodejs_22];

    programs.vscode.profiles.default = {
      extensions = with pkgs.vscode-marketplace;
      with pkgs.vscode-marketplace-release; [
        dbaeumer.vscode-eslint
        formulahendry.auto-rename-tag
      ];
      userSettings = {
        # Language Settings
        "[typescript]" = {
          "editor.detectIndentation" = false;
          "editor.tabSize" = 2;
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "typescript.updateImportsOnFileMove.enabled" = "always";

        "javascript.updateImportsOnFileMove.enabled" = "always";
        "[javascript]" = {
          "editor.defaultFormatter" = "vscode.typescript-language-features";
        };
      };
    };
  };
}
