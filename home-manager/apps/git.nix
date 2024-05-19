{vars, ...}:
{
  programs = {
    git = {
      enable = true;
      userEmail = vars.user.email;
      userName = vars.user.name;
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