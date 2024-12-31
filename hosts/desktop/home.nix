{
  lib,
  pkgs,
  ...
}: {
  home.stateVersion = "24.11";

  home.username = "niklas";
  home.homeDirectory = "/home/niklas";

  tarow = lib.mkMerge [
    (lib.tarow.enableModules [
      "angular"
      "core"
      "ghostty"
      "git"
      "gnome"
      "golang"
      "java"
      "npm"
      "react"
      "shells"
      "sshClient"
      "stylix"
      "vscode"
    ])
    {
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

  programs.zsh.plugins = [
    {
      name = "powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
    }
  ];

  #systemd.user.sessionVariables = config.home.sessionVariables;
}
