{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.tarow.neovim;
in {
  options.tarow.neovim = {
    enable = lib.mkEnableOption "Neovim";
  };

  imports = [inputs.nvf.homeManagerModules.default];

  config = lib.mkIf cfg.enable {
    home.shellAliases = {
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
    };
    programs.nvf = {
      enable = true;
      settings = {
        vim = {
          statusline.lualine.enable = true;
          telescope.enable = true;
          autocomplete.nvim-cmp.enable = true;

          languages = {
            enableLSP = true;
            enableTreesitter = true;
          };
        };
      };
    };
  };
}
