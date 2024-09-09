{ inputs, outputs, lib, config, pkgs, vars, ... }@args:


{
  config = {
    home.stateVersion = "24.05";

    home.username = lib.toLower vars.user.name;
    home.homeDirectory = vars.user.home;

    programs.home-manager.enable = true;

    news.display = "silent";

    home.sessionVariables = {
      EDITOR = "nvim";
    };

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
