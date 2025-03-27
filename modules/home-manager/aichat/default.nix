{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.aichat;

  wrapper = pkgs.symlinkJoin {
    name = "aichat";
    paths = [
      (pkgs.writeShellScriptBin "aichat" ''
        export GEMINI_API_KEY=''$(cat ${config.sops.secrets.GEMINI_API_KEY.path})
        exec ${lib.getExe pkgs.aichat} "$@"
      '')
      pkgs.aichat
    ];
  };
in {
  options.tarow.aichat = {
    enable = lib.options.mkEnableOption "aichat";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [wrapper];

    xdg.configFile."aichat/config.yaml".text = ''
      model: gemini
      clients:
      - type: gemini
    '';
  };
}
