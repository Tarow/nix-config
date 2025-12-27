{
  lib,
  config,
  pkgs,
  ...
} @ args: {
  config = {
    home.stateVersion = "24.05";

    home.username = "niklas";
    home.homeDirectory = "/home/niklas";

    programs.home-manager.enable = true;

    news.display = "silent";

    home.packages = [pkgs.vlc];

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    tarow = lib.mkMerge [
      (lib.tarow.enableModules [
        "angular"
        "core"
        "git"
        "golang"
        "java"
        "neovim"
        "nh"
        "npm"
        "react"
        "shells"
        "starship"
        "stylix"
        "vscode"
      ])
      {
        git-clone.repos.nix-config = {
          uri = "https://github.com/Tarow/nix-config.git";
          location = "~/projects";
        };
      }
    ];

    
  };
}
