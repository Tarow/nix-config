{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.copilot;
in {
  options.tarow.copilot = {
    enable = lib.options.mkEnableOption "copilot";
  };
  config = lib.mkIf cfg.enable {
    programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace;
    with pkgs.vscode-marketplace-release; [
      github.copilot
      github.copilot-chat
    ];

    programs.vscode.profiles.default.userSettings = {
      "github.copilot.nextEditSuggestions.enabled" = false;
    };
    programs.vscode.profiles.default.keybindings = [
      {
        key = "alt+right";
        command = "editor.action.inlineSuggest.commit";
      }
      {
        key = "tab";
        command = "-editor.action.inlineSuggest.commit";
        when = "inlineEditIsVisible && tabShouldAcceptInlineEdit && !editorHoverFocused && !editorTabMovesFocus && !suggestWidgetVisible || inlineSuggestionHasIndentationLessThanTabSize && inlineSuggestionVisible && !editorHoverFocused && !editorTabMovesFocus && !suggestWidgetVisible || inlineEditIsVisible && inlineSuggestionHasIndentationLessThanTabSize && inlineSuggestionVisible && !editorHoverFocused && !editorTabMovesFocus && !suggestWidgetVisible || inlineEditIsVisible && inlineSuggestionVisible && tabShouldAcceptInlineEdit && !editorHoverFocused && !editorTabMovesFocus && !suggestWidgetVisible";
      }
      {
        key = "tab";
        command = "-editor.action.inlineSuggest.commit";
        when = "inInlineEditsPreviewEditor";
      }
    ];
  };
}
