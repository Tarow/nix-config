{ inputs, outputs, lib, config, pkgs, ... }@args:
{
  config = {
    home.stateVersion = "24.05";

    home.username = "niklas";
    home.homeDirectory = "/home/niklas";

    programs.home-manager.enable = true;

    news.display  = "silent";

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
      uh = "home-manager switch -b bak --flake ~/projects/nix-config/#wsl2";
    };
  };
}
