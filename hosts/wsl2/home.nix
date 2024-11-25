{ inputs, outputs, lib, config, pkgs, ... }@args:
{
  config = {
    home.stateVersion = "24.05";

    home.username = "niklas";
    home.homeDirectory = "/home/niklas";

    programs.home-manager.enable = true;

    news.display = "silent";

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    tarow = lib.mkMerge [
      (lib.tarow.enableModules [
        "basics"
        "git"
        "shells"
        "golang"
        "npm"
        "react"
        "angular"
        "vscode"
      ])
      {
        basics.configLocation = "~/projects/nix-config#wsl2";
        git-clone.repos.nix-config = {
          uri = "https://github.com/Tarow/nix-config.git";
          location = "~/projects";
        };
      }
    ];

  };
}
