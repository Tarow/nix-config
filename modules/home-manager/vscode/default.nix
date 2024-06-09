{ pkgs, config, lib, ... }:

let
  cfg = config.tarow.vscode;
in
{
  options.tarow.vscode = {
    enable = lib.options.mkOption {
      type = lib.types.bool;
      example = ''true'';
      default = false;
      description = "Whether to enable vscode";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      mutableExtensionsDir = false;

      extensions = with pkgs.vscode-marketplace; with pkgs.vscode-marketplace-release;
        [
          azemoh.one-monokai
          pkief.material-icon-theme

          esbenp.prettier-vscode

          jnoortheen.nix-ide
          ms-vscode-remote.remote-ssh
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

        "[nix]" = {
          "editor.detectIndentation" = false;
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
          "editor.tabSize" = 2;
        };
      };
    };
  };
}
