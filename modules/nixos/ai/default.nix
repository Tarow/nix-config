{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.ai;
  user = "ai";
  uid = 1001;
  gid = 1001;
in {
  options.tarow.ai.enable = lib.mkEnableOption "AI coding agent user";

  config = lib.mkIf cfg.enable {
    users.groups.${user}.gid = gid;

    users.users.${user} = {
      isNormalUser = true;
      uid = uid;
      group = user;
      home = "/home/${user}";
      createHome = true;
      linger = true;
      shell = pkgs.fish;
      description = "AI coding agent";
      extraGroups = ["hm-nix-users"];
    };

    home-manager.users.${user} = {
      home.stateVersion = "26.05";

      tarow = {
        facts = {
          username = lib.mkForce user;
          uid = lib.mkForce uid;
          gid = lib.mkForce gid;
        };

        git.enable = true;
        claude-code.enable = true;

        opencode = {
          enable = true;
          expose = false;
          openchamber.enable = true;
        };
      };
    };
  };
}
