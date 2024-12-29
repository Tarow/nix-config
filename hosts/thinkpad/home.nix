{ inputs, outputs, lib, config, pkgs, ... }@args:


{
  config = {
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


    dconf.settings."org/gnome/shell".favorite-apps = with lib; [
      (if config.tarow.ghostty.enable then "com.mitchellh.ghostty.desktop" else "")
      "org.gnome.Nautilus.desktop"
      "org.gnome.Settings.desktop"
      "firefox.desktop"
      "org.telegram.desktop.desktop"
      "discord.desktop"
      "code.desktop"
      "obsidian.desktop"
      "org.gnome.Calendar.desktop"
    ];

    #systemd.user.sessionVariables = config.home.sessionVariables;
  };
}
