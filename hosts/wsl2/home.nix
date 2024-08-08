{ inputs, outputs, lib, config, pkgs, vars, ... }@args:

{
  #imports = [ ../../modules/home-manager ];

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
  };

  home.shellAliases = {
    hms = "home-manager switch -b bak --flake ~/projects/nix-config/#wsl2";
  };
}
