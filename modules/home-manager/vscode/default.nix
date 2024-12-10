{ lib, pkgs, config, ... }:
let
  cfg = config.tarow.vscode;
in
{
  options.tarow.vscode = {
    enable = lib.options.mkEnableOption "VSCode";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode.enable = true;
    programs.vscode.package = pkgs.unstable.vscode;
    programs.vscode.enableUpdateCheck = false;
    # Enable basic, shared settings here. Each module can add module-specific VSCode settings.
    programs.vscode.userSettings = {
      "terminal.integrated.defaultProfile.linux" = "fish";

      "terminal.integrated.commandsToSkipShell" = [
        "-workbench.action.terminal.focusFind"
      ];
      "remote.SSH.useLocalServer" = false;
      "remote.SSH.remotePlatform" = {
        "ntasler" = "linux";
        "ntasler.de" = "linux";
      };

      "editor.formatOnSave" = true;
      "editor.codeActionsOnSave" = {
        "source.organizeImports" = "explicit";
      };
      "editor.linkedEditing" = true;
      "editor.fontLigatures" = true;
      "editor.fontFamily" = "JetBrainsMono Nerd Font Mono";
      "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font Mono";
    };

    programs.vscode.extensions = with pkgs.vscode-marketplace; with pkgs.vscode-marketplace-release; [
      jnoortheen.nix-ide
      esbenp.prettier-vscode
    ];

    programs.vscode.keybindings = [{
      "key" = "ctrl+e";
      "command" = "terminal.focus";
    }];
  };
}
