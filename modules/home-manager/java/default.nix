{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.java;
  jdk = pkgs.jdk;
in {
  options.tarow.java = {
    enable = lib.options.mkEnableOption "Java";
  };
  config = lib.mkIf cfg.enable {
    programs.java.enable = true;
    programs.java.package = jdk;

    programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace;
    with pkgs.vscode-marketplace-release; [
      vscjava.vscode-java-pack
    ];

    programs.vscode.profiles.default.userSettings = {
      "java.jdt.ls.java.home" = jdk.home;
      "java.import.gradle.java.home" = jdk.home;
      "[java]" = {
        "editor.defaultFormatter" = "redhat.java";
      };
    };
  };
}
