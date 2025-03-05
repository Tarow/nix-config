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
    ip4Address = mkOption {
      type = types.str;
    };
  };

  config = {
    home.username = cfg.username;
    home.homeDirectory = "/home/${cfg.username}";
  };
}
