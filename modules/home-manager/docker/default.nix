{ lib, config, vars, pkgs, ... }:
let
  cfg = config.tarow.docker;

  shellAliases = {
    dc = "docker compose";
    dcu = "docker compose up -d";
    dcd = "docker compose down -v";
    dl = "docker logs";
    dlf = "docker logs -f";
  };
  shellFunctions = ''
    dsh () {
      docker exec -it "$1" /bin/sh; 
    }
    drun() {
      docker run --rm -it "$1" /bin/sh
    }
  '';

  shellAbbrs = shellAliases // {
    dsh = {
      expansion = "docker exec -it % /bin/sh";
      setCursor = true;
    };
    drun = { expansion = "docker run --rm -it % /bin/sh"; setCursor = true; };
  };
in
{
  options.tarow.docker =
    {
      enable = lib.options.mkOption {
        type = lib.types.bool;
        example = ''true'';
        default = false;
        description = "Whether to setup Docker-CLI and supporting tools. This will not setup the Docker daemon.";
      };
      enableAliases = lib.options.mkOption {
        type = lib.types.bool;
        example = ''true'';
        default = true;
        description = "Whether to setup Docker (Compose) aliases";
      };
    };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ docker ];

    programs = lib.mkIf cfg.enableAliases
      {
        bash.shellAliases = shellAliases;
        bash.initExtra = shellFunctions;

        zsh.shellAliases = shellAliases;
        zsh.initExtra = shellFunctions;

        fish.shellAbbrs = shellAbbrs;
      };
  };
}
