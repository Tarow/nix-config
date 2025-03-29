{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.aichat;
in {
  options.tarow.aichat = {
    enable = lib.options.mkEnableOption "aichat";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.aichat];
    home.shellAliases = {
      "ai" = lib.getExe pkgs.aichat;
    };

    sops.templates."aichat-config" = {
      content = ''
        model: deepseek:deepseek-chat

        clients:
          - type: gemini
            name: gemini
            api_key: ${config.sops.placeholder.GEMINI_API_KEY}

          - type: openai-compatible
            name: deepseek
            api_base: https://api.deepseek.com
            api_key: ${config.sops.placeholder.DEEPSEEK_API_KEY}
      '';
      path = "${config.xdg.configHome}/aichat/config.yaml";
    };
  };
}
