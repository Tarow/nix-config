{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    {
      tarow = lib.tarow.enableModules [
        "angular"
        "core"
        "direnv"
        "ghostty"
        "git"
        "gnome"
        #"golang"
        #"hyprland"
        "java"
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
      ];
    }
  ];

  tarow = {
    facts = import ../facts.nix;
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
      traefik.enable = true;
      traefik.domain = "nopshift.de";
      adguard = {
        enable = true;
      };
      calibre.enable = true;
      homepage.enable = true;
      audiobookshelf.enable = true;
      dozzle.enable = true;
      filebrowser.enable = true;
      paperless.enable = true;
      healthchecks.enable = true;
      immich.enable = true;
      mealie.enable = true;
    };

    sops.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };

  home.stateVersion = "24.11";

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

  xdg.configFile."containers/containers.conf".text = ''
    [network]
    dns_bind_port = 1153
  '';
}
