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

    person = {
      name = lib.options.mkOption {
        type = lib.types.str;
        example = ''Max Mustermann'';
        description = "Full name which will be used for Git config etc";
      };
      email = lib.options.mkOption {
        type = lib.types.str;
        example = ''max.mustermann@vodafone.om'';
        description = "E-mail address will be used for Git config etc";
      };
    };
  };
}
