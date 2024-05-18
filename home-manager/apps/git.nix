{
  programs ={
    git = {
      enable = false;
      userEmail = "niklastasler@gmail.com";
      userName = "Niklas";
      extraConfig = {
        init.defaultBranch = "main";
      };
    };
    gh = {
      enable = false;
      gitCredentialHelper.enable = true;
    };
  };
}