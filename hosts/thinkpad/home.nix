{
  lib,
  pkgs,
  ...
}: {
  home.stateVersion = "24.05";

  home.username = "niklas";
  home.homeDirectory = "/home/niklas";

  tarow = lib.mkMerge [
    (lib.tarow.enableModules [
      "aichat"
      "core"
      "git"
      "shells"
      "golang"
      "ghostty"
      "gnome"
      "sshClient"
      "starship"
      "stylix"
      # "sops"
      "vscode"
      "firefox"
    ])
    {
      core.configLocation = "~/nix-config#thinkpad";
      git-clone.repos.pkm = {
        uri = "git@github.com:Tarow/pkm.git";
        location = "~";
      };
    }
  ];

  home.packages = with pkgs; [
    bruno
    discord
    obsidian
    telegram-desktop
    unstable.teams-for-linux
    stremio
  ];

  #systemd.user.sessionVariables = config.home.sessionVariables;
}
