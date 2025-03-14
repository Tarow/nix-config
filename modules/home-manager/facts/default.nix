{config, ...}: let
  cfg = config.tarow.facts;
in {
  config = {
    home.username = cfg.username;
    home.homeDirectory = "/home/${cfg.username}";
  };
}
