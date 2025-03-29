{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    {
      tarow = lib.tarow.enableModules [
        "aichat"
        "angular"
        "core"
        "copilot"
        "direnv"
        "ghostty"
        "git"
        "gnome"
        "java"
        "mpv"
        "neovim"
        "npm"
        "react"
        "walker"
        "shells"
        "sshClient"
        "sops"
        "stacks"
        "stylix"
        "vscode"
        "zen-browser"
      ];
    }
  ];

  tarow = {
    facts.ip4Address = "10.1.1.210";
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

    sops.extraSopsFiles = [../../secrets/desktop/secrets.yaml];
  };

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    bruno
    discord
    obsidian
    telegram-desktop
    teams-for-linux
    unstable.bitwarden-desktop
    jellyfin-media-player
    stremio
  ];

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-1, 3440x1440@143.97, 0x0, 1"
      "HDMI-A-1, 2560x1440@59.95, 3440x0, 1"
    ];
  };

  #systemd.user.sessionVariables = config.home.sessionVariables;

  #services.podman.containers."podman1-exporter" = {
  #  image = "ealen/echo-server";
  #};
  programs.zellij.enable = true;
}
