{ pkgs, config, ... }:
{
  home.file.".vscode-server/data/Machine/settings.json".source = (pkgs.formats.json { }).generate "server-settings" config.programs.vscode.userSettings;
  home.file.".vscode-server/extensions".source = config.home.file.".vscode/extensions".source;
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;

    extensions = with pkgs.vscode-marketplace; with pkgs.vscode-marketplace-release;
      [
        azemoh.one-monokai
        bradlc.vscode-tailwindcss
        dbaeumer.vscode-eslint
        dsznajder.es7-react-js-snippets
        esbenp.prettier-vscode
        formulahendry.auto-rename-tag
        jnoortheen.nix-ide
        ms-vscode-remote.remote-ssh
        pkief.material-icon-theme
        redhat.vscode-yaml
      ];
    userSettings = {
      # Terminal
      "terminal.integrated.scrollback" = 1000000;
      "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font Mono";
      "terminal.integrated.shellIntegration.history" = 1000;
      "terminal.integrated.shellIntegration.enabled" = false;
      "terminal.integrated.enableMultiLinePasteWarning" = "never";
      "terminal.integrated.defaultProfile.linux" = "fish";
      "terminal.integrated.defaultProfile.osx" = "fish";
      "terminal.integrated.commandsToSkipShell" = [
        "-workbench.action.terminal.focusPreviousPane"
        "-workbench.action.terminal.focusNextPane"
        "-workbench.action.terminal.focusPreviousPane"
        "-workbench.action.terminal.focusNextPane"
        "-workbench.action.terminal.focusFind"
        "-workbench.action.quickOpenView"
        "-workbench.action.quickOpen"
      ];

      # Editor
      "editor.fontLigatures" = true;
      "editor.fontFamily" = "JetBrainsMono Nerd Font Mono";
      "editor.inlineSuggest.enabled" = true;
      "editor.tabSize" = 2;
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.formatOnSave" = true;
      "editor.codeActionsOnSave" = {
        "source.organizeImports" = "always";
      };

      # Workbench
      "workbench.colorTheme" = "One Monokai";
      "workbench.iconTheme" = "material-icon-theme";

      # Explorer
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;

      # Security
      "security.workspace.trust.untrustedFiles" = "open";

      # Remote Connections
      "remote.SSH.remotePlatform" = {
        "wsl2" = "linux";
        "wsl-demo" = "linux";
        "ntasler" = "linux";
      };

      # Misc
      "git.autofetch" = true;

      # Language Settings
      "[typescript]" = {
        "editor.detectIndentation" = false;
        "editor.tabSize" = 2;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "typescript.updateImportsOnFileMove.enabled" = "always";

      "files.associations" = {
        "*.tsx" = "typescriptreact";
      };
      "[typescriptreact]" = {
        "editor.detectIndentation" = false;
        "editor.tabSize" = 2;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };


      "[nix]" = {
        "editor.detectIndentation" = false;
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
        "editor.tabSize" = 2;
      };

      "javascript.updateImportsOnFileMove.enabled" = "always";
      "[javascript]" = {
        "editor.defaultFormatter" = "vscode.typescript-language-features";
      };

    };
  };
}
