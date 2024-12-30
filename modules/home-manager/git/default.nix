{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.git;
  shellAbbrs = {
    gl = "git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit";
    gco = "git checkout";
    gcb = "git checkout -b";
    gpl = "git pull";
    gp = "git push";
    gcm = {
      expansion = "git commit -m \"%\"";
      setCursor = true;
    };
    gcma = {
      expansion = "git commit --amend -m \"%\"";
      setCursor = true;
    };
    ga = "git add";
    gfa = "git fetch --all";
  };

  shellAliases =
    shellAbbrs
    // {
      gcm = ''git commit -m'';
      gcma = ''git commit --amend -m'';
    };
in {
  options.tarow.git = {
    enable = lib.options.mkOption {
      type = lib.types.bool;
      example = ''true'';
      default = false;
      description = "Whether to enable git support and setup aliases";
    };
  };
  config.programs = lib.mkIf cfg.enable {
    git = {
      enable = true;
      userEmail = config.tarow.person.email;
      userName = config.tarow.person.name;
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = false;
      };
      signing = {
        key = lib.mkDefault null;
        signByDefault = config.programs.git.signing.key != null;
      };
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      gitCredentialHelper.hosts = ["https://github.vodafone.com" "https://github.com"];
    };

    bash.shellAliases = shellAliases;
    zsh.shellAliases = shellAliases;
    fish.shellAbbrs = shellAbbrs;
  };
}
