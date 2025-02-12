{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.shells;
in {
  options.tarow.shells = {
    enable = lib.options.mkOption {
      type = lib.types.bool;
      example = ''true'';
      default = false;
      description = "Whether to enable shell support";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable shell support
    programs.bash.enable = true;
    programs.fish.enable = true;
    programs.zsh.enable = true;

    # Setup starship for bash and zsh, for fish we use tide by default
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = false;
    };

    # Additional fish setup
    programs.fish.shellInit =
      ''
        set fish_greeting "Welcome to the 🐟 shell"
        bind \cR _fzf_search_history
        fzf_configure_bindings --directory=è --history=\cR --processes=ô --variables=ë --git_status=ß --git_log=ø;
      ''
      + lib.strings.optionalString pkgs.stdenv.isDarwin ''
        # fixes path order issues, see https://github.com/LnL7/nix-darwin/issues/122 (https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1266049484)
        for p in (string split " " $NIX_PROFILES); fish_add_path --prepend --move $p/bin; end
      '';
    programs.fish.plugins = with pkgs.fishPlugins; [
      {
        name = "tide";
        src = tide.src;
      }
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
    # Setup tide if its not initialized yet
    home.extraActivationPath = [pkgs.fish];
    home.activation.shells = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run fish -c 'set -q tide_prompt_transient_enabled || tide configure --auto --style=Lean --prompt_colors="True color" --show_time="24-hour format" \
       --lean_prompt_height="Two lines" --prompt_connection=Disconnected --prompt_spacing=Compact --icons="Few icons" --transient=No'
    '';

    # Dependencies for Abbreviations and plugins
    home.packages = with pkgs; [xclip less gnugrep] ++ [bat eza fd fzf];

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
        expansion = "| grep %";
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
