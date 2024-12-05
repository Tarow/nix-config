{ inputs, outputs, lib, config, pkgs, ... }@args:

{
  config = {
    home.stateVersion = "24.11";

    home.username = "niklas";
    home.homeDirectory = "/home/niklas";

    tarow = lib.mkMerge [
      (lib.tarow.enableModules [
        "angular"
        "basics"
        "git"
        "shells"
        "golang"
        "gnome"
        "npm"
        "react"
        "sshClient"
        "java"
        "vscode"
      ])
      {
        basics.configLocation = "~/nix-config#desktop";
        git-clone.repos = {
          nix-config = {
            uri = "https://github.com/Tarow/nix-config.git";
            location = "~";
          };
          pkm = {
            uri = "https://github.com/Tarow/pkm.git";
            location = "~";
          };
        };
      }
    ];

    programs.firefox.enable = true;
    home.packages = with pkgs; [
      discord
      obsidian
      telegram-desktop
    ];

    #systemd.user.sessionVariables = config.home.sessionVariables;
  };
}
