{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.golang;
in {
  options.tarow.golang = {
    enable = lib.options.mkOption {
      type = lib.types.bool;
      example = ''true'';
      default = false;
      description = "Whether to enable Go and setup integrations";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      air
      go
      golangci-lint
      gopls
      gotools
      gnumake
    ];

    programs.vscode.profiles.default = {
      extensions = with pkgs.vscode-marketplace;
      with pkgs.vscode-marketplace-release; [
        golang.go
      ];

      userSettings = {
        "[go]" = {
          "editor.parameterHints.enabled" = true;
          "editor.insertSpaces" = false;
          "editor.formatOnSave" = true;
          "editor.codeActionsOnSave" = {
            "source.organizeImports" = "always";
          };
          "editor.suggest.snippetsPreventQuickSuggestions" = false;
          "editor.defaultFormatter" = "golang.go";
        };
        "gopls" = {
          "ui.completion.usePlaceholders" = true;
        };
        "go.survey.prompt" = false;
        "go.formatTool" = "goimports";
        "go.lintTool" = "golangci-lint";
        "go.lintFlags" = [
          "--fast"
        ];
        "go.inlayHints.parameterNames" = true;
        "go.toolsManagement.autoUpdate" = true;
      };
    };

    programs.nvf.settings.vim.languages = {
      go = {
        enable = true;
      };
    };
  };
}
