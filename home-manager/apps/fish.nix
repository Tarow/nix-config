{ config, lib, pkgs, ... }:
{
  programs.fish = {
    enable = true;
    plugins = with pkgs.fishPlugins; [
      { name = "tide"; src = tide.src; } 
      { name = "fzf-fish"; src = fzf-fish.src; } 
      { name = "z"; src = z.src; }
      { name = "sponge"; src = sponge.src; }
      { name = "autopair"; src = autopair.src; }
      {
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
    ];
    interactiveShellInit = ''
      bind \\cr _fzf_search_history
      fzf_configure_bindings --directory=è --history=\cR --processes=ô --variables=ë --git_status=ß --git_log=ø
      set sponge_delay 10
    '';

    shellAbbrs = {
      L = {position = "anywhere"; expansion = "% | less"; setCursor = true;};
      G = {position = "anywhere"; expansion = "| grep %"; setCursor = true;};
    } // lib.optionalAttrs config.programs.git.enable {
      gco   = "git checkout";
      gcb   = "git checkout -b";
      gpl   = "git pull";
      gp    = "git push";
      gcm   = {expansion = "git commit -m \"%\""; setCursor = true;};
      gcma  = {expansion = "git commit --amend -m \"%\""; setCursor = true;};
      ga    = "git add";
      gfa   = "git fetch --all";
    } // {
      dc    = "docker compose";
      dcu   = "docker compose up -d";
      dcd   = "docker compose down -v";
      dl    = "docker logs";
      dlf   = "docker logs -f";
      dsh   = {expansion = "docker exec -it $ /bin/sh"; setCursor = true;};
      drun  = {expansion = "docker run --rm -it % /bin/sh"; setCursor = true;};
    } // {
      hm = "home-manager";
    };
  };
}