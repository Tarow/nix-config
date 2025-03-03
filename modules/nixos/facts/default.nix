{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tarow.facts;
in {
  options.tarow.facts = with lib; {
    username = mkOption {
      type = types.str;
      readOnly = true;
    };
    userhome = mkOption {
      type = types.str;
      readOnly = true;
      default = config.users.users.${cfg.username}.home;
    };
    uid = mkOption {
      type = types.int;
      readOnly = true;
    };
    gid = mkOption {
      type = types.int;
      readOnly = true;
    };
    ip4Address = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

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
