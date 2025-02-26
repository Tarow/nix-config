{
  config,
  lib,
  ...
}: let
  cfg = config.tarow.facts;
in {
  options.tarow.facts = with lib; {
    username = mkOption {
      type = types.str;
    };
    uid = mkOption {
      type = types.int;
    };
    gid = mkOption {
      type = types.int;
    };
  };

  config = {
    home.username = cfg.username;
    home.homeDirectory = "/home/${cfg.username}";
  };
}
