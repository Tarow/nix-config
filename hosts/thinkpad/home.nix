{ inputs, outputs, lib, config, pkgs, ... }@args:


{
  config = {
    home.stateVersion = "24.05";

    home.username = "niklas";
    home.homeDirectory = "/home/niklas";

    home.sessionVariables = {
      EDITOR = "nvim";
    };

    programs.vscode.enable = true;
    tarow = {
      basics.enable = true;
      git.enable = true;
      shell.enable = true;
      golang.enable = true;
      npm.enable = true;
      react.enable = true;
      docker = {
        traefik = {
          enable = true;
          domain = "ntasler.de";
          network = "traefik-proxy";
        };
        adguard.enable = true;
      };
    };

    home.shellAliases = {
      uh = "home-manager switch -b bak --flake ~/nix-config/#thinkpad";
    };

    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        show-all-sources = true;
        sources = [
          [ "xkb" "eu" ]
        ];
      };
    };
  };
}
