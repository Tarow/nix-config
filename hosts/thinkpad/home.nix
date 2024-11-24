{ inputs, outputs, lib, config, pkgs, ... }@args:


{
  config = {
    home.stateVersion = "24.05";

    home.username = "niklas";
    home.homeDirectory = "/home/niklas";

    tarow = lib.mkMerge [
      (lib.tarow.enableModules [
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
        basics.configLocation = "~/nix-config#thinkpad";
        git-clone.repos.pkm = {
          uri = "git@github.com:Tarow/pkm.git";
          location = "~";
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
