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

        languages.enableTreesitter = true;

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };
        #startPlugins = ["cheatsheet-nvim"];

        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;

        filetree.nvimTree.enable = true;

        ui = {
          colorizer.enable = true;
        };
        statusline = {
          lualine = {
            enable = true;
            integrations = {
              breadcrumbs = {
                nvim-navic = {
                  enable = true;
                  alwaysRender = true;
                };
                navbuddy.enable = true;
              };
            };
          };
        };
      };
    };
  };
}
