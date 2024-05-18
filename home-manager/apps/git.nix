{
  programs ={
    git = {
      enable = true;
      userEmail = "niklastasler@gmail.com";
      userName = "Niklas";
      extraConfig = {
        init.defaultBranch = "main";
      };
    };
    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
  };
}