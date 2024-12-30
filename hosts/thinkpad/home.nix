{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
} @ args: {
  home.stateVersion = "24.05";

  home.username = "niklas";
  home.homeDirectory = "/home/niklas";

  tarow = lib.mkMerge [
    (lib.tarow.enableModules [
      "angular"
      "basics"
      "git"
      "shells"
      "golang"
      "ghostty"
      "gnome"
      "npm"
      "react"
      "sshClient"
      "java"
      "stylix"
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
    bruno
    discord
    obsidian
    telegram-desktop
    teams-for-linux
  ];

  #systemd.user.sessionVariables = config.home.sessionVariables;
}
