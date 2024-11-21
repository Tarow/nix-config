{ inputs, outputs, lib, config, pkgs, ... }@args:


{
  config = {
    home.stateVersion = "24.05";

    home.username = "niklas";
    home.homeDirectory = "/home/niklas";

    tarow = lib.mkMerge [
      (lib.tarow.enableModules [
        "basics"
        "git"
        "shells"
        "golang"
        "gnome"
        "npm"
        "react"
        "vscode"
      ])
      {
        basics.configLocation = "~/nix-config#thinkpad";
      }
    ];

  };
}
