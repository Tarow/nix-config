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
      readOnly = true;
    };
    uid = mkOption {
      type = types.int;
      readOnly = true;
    };
    gid = mkOption {
      type = types.int;
      readOnly = true;
    };
  };

  config = {
    home.username = cfg.username;
    home.homeDirectory = "/home/${cfg.username}";
  };
}
