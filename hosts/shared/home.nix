{pkgs, ...}: {
  tarow.person = {
    email = "niklastasler@gmail.com";
    name = "Niklas Tasler";
  };

  tarow.facts = import ../facts.nix;

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
  news.display = "silent";
}
