# Facts module, mainly used for values that are used by NixOS as well as HM modules
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
    userhome = mkOption {
      type = types.str;
      readOnly = true;
      default = "/home/${cfg.username}";
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
}
