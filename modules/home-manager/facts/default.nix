{
  config,
  lib,
  ...
}: let
  cfg = config.tarow.facts;
in {
  config = {
    home.username = lib.mkDefault cfg.username;
    home.homeDirectory = lib.mkDefault "/home/${cfg.username}";
  };
}
