{ lib, pkgs, config, ... }:
let
  cfg = config.tarow.shell;
in
{
  options.tarow.shell = {
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
        
        # fixes path order issues, see https://github.com/LnL7/nix-darwin/issues/122 (https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1266049484)
        for p in (string split " " $NIX_PROFILES); fish_add_path --prepend --move $p/bin; end
        bind \cR _fzf_search_history
        fzf_configure_bindings --directory=è --history=\cR --processes=ô --variables=ë --git_status=ß --git_log=ø;
      '';
    programs.fish.plugins = with pkgs.fishPlugins; [
      { name = "tide"; src = tide.src; }
      { name = "fzf-fish"; src = fzf-fish.src; }
      { name = "z"; src = z.src; }
      { name = "sponge"; src = sponge.src; }
      { name = "autopair"; src = autopair.src; }
    ];
    # Dependencies for Abbreviations and plugins
    home.packages = with pkgs; [ less gnugrep ] ++ [ bat eza fd fzf ];

    programs.fish.shellAbbrs = {
      L = {
        position = "anywhere";
        expansion = "% | less";
        setCursor = true;
      };
      G = { position = "anywhere"; expansion = "| grep %"; setCursor = true; };
    };

    home.shellAliases = {
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      cat = "bat --paging=never";
      tree = "eza -T";
    };

  };
}
