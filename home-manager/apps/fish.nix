{ config, pkgs, ... }:
{
  programs.fish = {
    enable = true;
    plugins = with pkgs.fishPlugins; [
       { name = "tide"; src = tide.src; } 
       { name = "fzf-fish"; src = fzf-fish.src; } 
       { name = "z"; src = z.src; }
       { name = "sponge"; src = sponge.src; }
       { name = "autopair"; src = autopair.src; }
    ];
    interactiveShellInit = ''
      bind \\cr _fzf_search_history
    '';
  };
}