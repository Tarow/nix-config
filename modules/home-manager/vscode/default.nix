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

    # Enable basic, shared settings here. Each module can add module-specific VSCode settings.
    programs.vscode.userSettings = {
      "editor.formatOnSave" = true;
      "terminal.integrated.defaultProfile.linux" = "fish";
    };
  };
}
