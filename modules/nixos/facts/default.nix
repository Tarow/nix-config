{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tarow.facts;
in {
  imports = [(lib.mkAliasOptionModule ["users" "mainUser"] ["users" "users" cfg.username])];

  config = {
    users.groups.${cfg.username} = {
      inherit (cfg) gid;
    };

    users.users.${cfg.username} = {
      isNormalUser = true;
      description = cfg.username;

      uid = cfg.uid;
      group = config.users.groups.${cfg.username}.name;

      extraGroups = ["users" "wheel" (lib.mkIf config.tarow.networkManager.enable "networkmanager")];
      shell = pkgs.fish;
      linger = true;
    };
  };
}
