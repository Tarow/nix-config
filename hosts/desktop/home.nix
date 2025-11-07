{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./stacks.nix
    {
      tarow = lib.tarow.enableModules [
        "aichat"
        "angular"
        "cmdmark"
        "core"
        "copilot"
        "direnv"
        "firefox"
        "ghostty"
        "git"
        "golang"
        "gnome"
        "java"
        "mpv"
        "neovim"
        "npm"
        "react"
        "shells"
        "starship"
        "sshClient"
        "sops"
        "stylix"
        "vscode"
        "zen-browser"
        "podman"
      ];
    }
  ];

  tarow = {
    facts.ip4Address = "10.1.1.148";
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
    unstable.teams-for-linux
    unstable.bitwarden-desktop
    jellyfin-media-player
    stremio
    pinta
    glow
  ];

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-1, 3440x1440@143.97, 0x0, 1"
      "HDMI-A-1, 2560x1440@59.95, 3440x0, 1"
    ];
  };

  programs.zellij.enable = true;
}
