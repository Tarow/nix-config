{pkgs, ...}: {
  tarow.facts.person = {
    email = "niklastasler@gmail.com";
    name = "Niklas Tasler";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
  news.display = "silent";
}
