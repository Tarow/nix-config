{
  lib,
  pkgs,
  ...
}: {
  imports = [
    {
      tarow = lib.tarow.enableModules [
        "angular"
        "core"
        "ghostty"
        "git"
        "gnome"
        "golang"
        #"hyprland"
        "java"
        "neovim"
        "npm"
        "react"
        "walker"
        "shells"
        "sshClient"
        "stacks"
        "stylix"
        "vscode"
      ];
    }
  ];

  tarow = {
    core.configLocation = "~/nix-config#desktop";
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
    monitors.configuration = ./monitors.xml;

    stacks = {
      enable = true;
      traefik.enable = true;
      traefik.domain = "test.de";
      adguard.enable = true;
    };
  };

  home.stateVersion = "24.11";
  home.username = "niklas";
  home.homeDirectory = "/home/niklas";

  programs.firefox.enable = true;
  home.packages = with pkgs; [
    bruno
    discord
    obsidian
    telegram-desktop
    teams-for-linux
  ];

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-1, 3440x1440@143.97, 0x0, 1"
      "HDMI-A-1, 2560x1440@59.95, 3440x0, 1"
    ];
  };

  #systemd.user.sessionVariables = config.home.sessionVariables;
}
