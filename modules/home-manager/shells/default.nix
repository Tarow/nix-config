{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.tarow.shells;
in
{
  options.tarow.shells.enable = lib.mkEnableOption "Shell Support";

  config = lib.mkIf cfg.enable {
    programs.bash.enable = true;
    programs.fish.enable = true;
    programs.zsh.enable = true;

    programs.fish.shellInit = ''
      set fish_greeting "🐟"
      set sponge_delay 5
      set sponge_purge_only_on_exit true
      bind \cR _fzf_search_history
      fzf_configure_bindings --directory=è --history=\cR --processes=ô --variables=ë --git_status=ß --git_log=ø;
    '';
    programs.fish.plugins = with pkgs.fishPlugins; [
      {
        name = "fzf-fish";
        src = fzf-fish.src;
      }
      {
        name = "z";
        src = z.src;
      }
      {
        name = "sponge";
        src = sponge.src;
      }
      {
        name = "autopair";
        src = autopair.src;
      }
    ];

    # Dependencies for Abbreviations and plugins
    home.packages =
      with pkgs;
      [
        xclip
        less
        gnugrep
      ]
      ++ [
        bat
        eza
        fd
        fzf
      ];

    programs.fish.shellAbbrs = rec {
      C = {
        position = "anywhere";
        expansion = "| xclip %";
        setCursor = true;
      };
      L = {
        position = "anywhere";
        expansion = "% | less";
        setCursor = true;
      };
      G = {
        position = "anywhere";
        expansion = "| grep -i %";
        setCursor = true;
      };
      F = {
        position = "anywhere";
        expansion = "| fzf %";
        setCursor = true;
      };
      sctl = "systemctl";
      suctl = sctl + " --user";

      jctl = "journalctl";
      juctl = jctl + " --user";
    };

    home.shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      cat = "bat --paging=never";
      tree = "eza -T";
      xclip = "xclip -selection clipboard";
    };
  };
}
