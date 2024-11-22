{ pkgs, ... }:
{
  tarow.person = {
    email = "niklastasler@gmail.com";
    name = "Niklas Tasler";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  fonts.fontconfig.enable = true;
  home.packages = [ (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];

  programs.home-manager.enable = true;
  news.display = "silent";
}
