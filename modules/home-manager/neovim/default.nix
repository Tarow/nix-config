{
  lib,
  config,
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
      enableManpages = true;
      settings.vim = {
        options = {
          autoindent = true;
          tabstop = 4;
          shiftwidth = 4;
        };

        globals = {
          mapleader = " ";
          maplocalleader = " ";
        };

        languages = {
          #enableTreesitter = true;
        };

        lsp = {
          enable = true;
          formatOnSave = true;
        };

        lineNumberMode = "number";
        preventJunkFiles = true;
        clipboard = {
          enable = true;
          registers = "unnamedplus";
        };

        binds = {
          whichKey.enable = true;

          cheatsheet.enable = true;
        };
        startPlugins = ["cheatsheet-nvim"];

        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;
        minimap.codewindow.enable = true;
        filetree.nvimTree.enable = true;

        ui = {
          colorizer.enable = true;
          breadcrumbs = {
            enable = true;
            lualine.winbar.alwaysRender = true;
            navbuddy.enable = true;
          };
        };
      };
    };
  };
}
